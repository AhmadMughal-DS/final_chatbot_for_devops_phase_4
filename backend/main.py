from fastapi import FastAPI, Request, Form, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr
import os
from openai import OpenAI
from datetime import datetime
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Import database functions from curd_mongodb module
from curd_mongodb import create_user, get_user_by_credentials, save_chat, get_chat_history, client, db, check_db_connection

# Set up configuration
DEBUG = os.getenv("DEBUG", "0") == "1"

# Get OpenAI API key from environment variable
OPENAI_API_KEY = os.getenv("openai", os.getenv("OPENAI_API_KEY"))

if not OPENAI_API_KEY:
    print("WARNING: OpenAI API key not found in .env file!")
    print("Please add 'openai=your-api-key' to your .env file")

# Initialize OpenAI client
openai_client = OpenAI(
    api_key=OPENAI_API_KEY,
)

model = "gpt-3.5-turbo"
stream = False
app = FastAPI()

# Enable CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Set up Jinja2 templates using the existing frontend directory
template_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "frontend")
templates = Jinja2Templates(directory=template_path)

print(f"Using template directory: {template_path}")

# Pydantic models
class QueryRequest(BaseModel):
    user_id: str
    message: str


@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.get("/health")
async def health_check():
    """Health check endpoint for Kubernetes probes"""
    health_status = {
        "status": "healthy",
        "timestamp": datetime.utcnow().isoformat(),
        "service": "devops-chatbot",
        "version": "1.0.0"
    }
    
    # Test MongoDB connection
    db_connected = await check_db_connection()
    health_status["database"] = "connected" if db_connected else "disconnected"
    
    if not db_connected:
        health_status["status"] = "degraded"
        health_status["warning"] = "Database connection unavailable"
    
    return health_status

@app.post("/signup")
async def signup(request: Request, email: EmailStr = Form(...), password: str = Form(...)):
    user = await create_user(email, password)
    
    if not user:
        return templates.TemplateResponse(
            "signup.html", 
            {"request": request, "error": "This email is already registered. Please log in."}
        )
    
    return RedirectResponse(url="/signin", status_code=303)

@app.get("/signup", response_class=HTMLResponse)
async def get_signup(request: Request):
    return templates.TemplateResponse("signup.html", {"request": request})

@app.get("/signin", response_class=HTMLResponse)
async def get_signin(request: Request):
    error = request.query_params.get("error", "")
    return templates.TemplateResponse("signin.html", {"request": request, "error": error})

@app.post("/signin")
async def signin_post(request: Request, email: EmailStr = Form(...), password: str = Form(...)):
    user = await get_user_by_credentials(email, password)
    
    if user:
        user_id_str = str(user['_id'])
        return RedirectResponse(url=f"/welcome?user_id={user_id_str}", status_code=303)
    
    return RedirectResponse(url="/signin?error=Invalid credentials", status_code=303)

@app.get("/welcome", response_class=HTMLResponse)
async def welcome(request: Request):
    user_id = request.query_params.get("user_id", "")
    
    if not user_id:
        return RedirectResponse(url="/signin", status_code=303)
    
    return templates.TemplateResponse("welcome.html", {"request": request, "user_id": user_id})


@app.post("/ask-devops-doubt")
async def ask_devops_doubt(request: QueryRequest):
    system_prompt = """
    You are a helpful assistant that solves doubts about the DevOps class taught by Sir Qasim Malik.
    Sir Qasim Malik is a DevOps Engineer and Instructor at the COMSATS university islamabad
    he teach us Git github OS aws aws-ec2 Jenkins kubernetes docker docker-compose.
    Ask questions related to these topics and provide clear, concise answers.
    if question is not related to these topics then say "I am sorry, I can only answer questions related to DevOps topics taught by Sir Qasim Malik."
    """

    try:
        chat_completion = openai_client.chat.completions.create(
            model=model,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": request.message},
            ],
            stream=stream,
            max_tokens=1000,
        )
        
        if stream:
            full_response = ""
            for chunk in chat_completion:
                if hasattr(chunk, 'choices') and len(getattr(chunk, 'choices', [])) > 0:
                    delta = getattr(chunk.choices[0], 'delta', None)  # type: ignore
                    if delta and hasattr(delta, 'content'):
                        content = getattr(delta, 'content', '')
                        if content:
                            full_response += content
            response = full_response.strip()
        else:
            message = chat_completion.choices[0].message  # type: ignore
            response = message.content.strip() if message.content else "No response generated"
        
        # Save question and answer to DB
        await save_chat(request.user_id, request.message, "user")
        await save_chat(request.user_id, response, "bot")
        
        return {"response": response}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to communicate with OpenAI API: {str(e)}")

@app.get("/chat-history")
async def get_user_chat_history(user_id: str):
    """Endpoint to retrieve chat history for a specific user"""
    if not user_id:
        return {"history": [], "error": "No user ID provided"}
    
    history = await get_chat_history(user_id)
    return {"history": history}