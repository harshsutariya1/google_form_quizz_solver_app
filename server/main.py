from fastapi import FastAPI
import requests
from bs4 import BeautifulSoup
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI

app = FastAPI()
# client = OpenAI()

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins, or specify your web app's URL for better security
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/get_quiz_data")
def get_quiz_data(google_form_link: str = "https://forms.gle/QTovj8DYWRXAQdu67"):
    
    header_tag = {'div':'ahS2Le'}
    question_container_tag = {'div':'geS5n'}
    question_tag = {'span':'M7eMe'}
    options_list_tag = {'div':'SG0AAe'}
    option_tag = {'div':'ulDsOb'}
    short_ans_input_tag  = {'div':'Xb9hP'}
    
    try:
        form_url = google_form_link
        response = requests.get(form_url)
        print(f"Status code: {response.status_code}")

        if response.status_code == 200:
            soup = BeautifulSoup(response.content, 'html.parser')
            
            # get header text
            header = soup.find('div', class_=header_tag['div']).text
            
            quiz_data = [{
                'form_link': google_form_link,
                'header': header,
            }]
            
            # Checking the div classes where questions and options are located.
            questions_containers = soup.find_all('div', class_=question_container_tag['div'])
            print(f"Questions found: {len(questions_containers)}")

            for index, question_container in enumerate(questions_containers):
                try:
                    print(f"\nProcessing question {index + 1}...")
                    
                    # print(question_container.text.__contains__(short_ans_input_tag['div']))
                    # Extract question
                    question:str = question_container.find('span', class_=question_tag['span']).text.strip()
                    if question:
                        print("Question:", question)
                    else:
                        print("Question not found.")
                        continue
                    
                    # Extract list of options
                    options:list[str] = []
                    
                    try:
                        options_div = question_container.find('div', class_=options_list_tag['div']) 
                        if options_div:
                            options_list = options_div.find_all('div', class_=option_tag['div'])
                            if options_list:
                                for option in options_list:
                                    print("Option:", option.text.strip(),)
                                    options.append(option.text.strip())
                                print(options)
                            else:
                                print("Options list not found.")
                        else:
                            print("Options div Not found.")
                    except Exception as error:
                        print("An error occured while getting options:",error)
                            
                    quiz_data.append({
                        'question': question,
                        'options': options
                    })
                
                except Exception as error:
                    print("An error occurred while looping through question container:", error)
                    continue
                
        else:
            print("Failed to retrieve the form. Status code:", response.status_code)

    except Exception as error:
        print("An error occurred:", error)

    print("Returned: \n",quiz_data)
    return quiz_data

@app.get("/generate_response")
def generate_response():
    print("Generating answer from chat gpt")
    # completion = client.chat.completions.create(
    #     model="gpt-4o",
    #     messages=[
    #         {"role": "system", "content": "You are a helpful assistant."},
    #         {
    #             "role": "user",
    #             "content": "Hello."
    #         }
    #     ]
    # )

    # print(completion.choices[0].message)
    
    # sample response
    return ["", "", "true", "No"]