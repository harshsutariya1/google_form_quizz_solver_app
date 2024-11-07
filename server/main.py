from fastapi import FastAPI, HTTPException, Request
import requests
from bs4 import BeautifulSoup
from fastapi.middleware.cors import CORSMiddleware
from openai import OpenAI

app = FastAPI()

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins, 
    # or specify your web app's URL for better security
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
                        print("Question Found")
                    else:
                        print("Question not Found.")
                        continue
                    
                    # Extract list of options
                    options:list[str] = []
                    
                    try:
                        options_div = question_container.find('div', class_=options_list_tag['div']) 
                        if options_div:
                            options_list = options_div.find_all('div', class_=option_tag['div'])
                            if options_list:
                                for option in options_list:
                                    # print("Option:", option.text.strip(),)
                                    options.append(option.text.strip())
                                # print(options)
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

    # print("Returned: \n",quiz_data)
    return quiz_data


@app.post("/generate_response")
async def generate_response(request: Request):
    data = await request.json()  # Parse JSON data
    openAiModel = data.get('openAiModel', '')
    print("Ai Model: ",openAiModel)
    client = OpenAI(
        api_key= data.get('openAiApiKey', '')
    )
    print("Generating answers from chat gpt")
    
    questions = data.get("questions", [])
    # print("Question to answer:", questions)

    # Initialize the list to store answers
    answers = []
    total_tokens = 0
    prompt_tokens = 0
    completion_token = 0

    for index, question in enumerate(questions):
        try:
             # Extract question text and options
            question_text = question.get('question', "")
            options = question.get('options', [])
            
            # Format the prompt string
            if options != []:
                prompt = f"Question: {question_text}. Options: {', '.join(options)}"
            else:
                prompt = f"Question: {question_text}"

            # print(f"Prompt for ChatGPT: {prompt}")
            
            # Generate answer for each question
            completion = client.chat.completions.create(
                # model="gpt-3.5-turbo-0125",
                model= openAiModel,
                messages=[
                    {"role": "system", "content": "you will get a question with options, return answer in one line or return correct option with description in one line, give funny answer for personal questions."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0,
            )
            
            # Append answer to the list
            answer = completion.choices[0].message.content
            if answer:
                print(f"\nGot answer for question {index + 1}: {answer}\n")
            answers.append(answer)
            
            # Access the token usage information
            usage = completion.usage
            total_tokens += usage.total_tokens
            prompt_tokens += usage.prompt_tokens
            completion_token += usage.completion_tokens
            
            # print(f"Question: {question_text}")
            # print(f"Answer: {answer}\n")

        except Exception as e:
            print(f"Error generating answer for question '{question}': {e}")
            raise HTTPException(status_code=500, detail="Error generating response")

    print("Prompt tokens:", prompt_tokens)
    print("Completion tokens:",completion_token)
    print("Total tokens:", total_tokens)
    answers.append(total_tokens)
    print("Ai Model Used:", openAiModel, '\n')
    
    # Return the list of answers
    return answers
