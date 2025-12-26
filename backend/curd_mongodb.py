from motor.motor_asyncio import AsyncIOMotorClient
from bson.json_util import dumps, loads
from pymongo import MongoClient
from bson import ObjectId
from datetime import datetime
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Set up DB connection for chatbot with error handling
MONGODB_URI = os.getenv("MONGODB_URI", "mongodb+srv://ahmadzafar:IUzvD9FvjOjHoqPR@devops.fzvip.mongodb.net/")
DEBUG = os.getenv("DEBUG", "0") == "1"

# Initialize MongoDB client with lazy connection
client = None
db = None

try:
    print(f"Initializing MongoDB client...")
    # Don't connect immediately - connection happens on first use
    client = AsyncIOMotorClient(
        MONGODB_URI, 
        serverSelectionTimeoutMS=5000,
        connectTimeoutMS=5000
    )
    # Use correct database name from MongoDB Atlas
    db = client["DevOps-Projects"]  # Changed from devops_assignment
    print("MongoDB client initialized (connection will be established on first use)")
except Exception as e:
    print(f"Warning: MongoDB client initialization failed: {str(e)}")
    print("Application will continue but database features may not work")
    # Set to None so we can check later
    client = None
    db = None

async def check_db_connection():
    """Check if database connection is available"""
    if client is None or db is None:
        return False
    try:
        await client.admin.command('ping')
        return True
    except Exception as e:
        print(f"Database connection check failed: {str(e)}")
        return False

async def create_user(email: str, password: str):
    """Check if user already exists based on email"""
    if db is None:
        print("Database not available")
        return None
    try:
        existing_user = await db.users.find_one({"email": email})
        if existing_user:
            return None  # Account already exists
        user = {"email": email, "password": password}
        result = await db.users.insert_one(user)
        user['_id'] = result.inserted_id
        return user
    except Exception as e:
        print(f"Error creating user: {str(e)}")
        return None

async def get_user_by_credentials(email: str, password: str):
    if db is None:
        print("Database not available")
        return None
    try:
        return await db.users.find_one({"email": email, "password": password})
    except Exception as e:
        print(f"Error getting user: {str(e)}")
        return None

async def save_chat(user_id, message, sender):
    """Save a chat message for a specific user."""
    if db is None:
        print("Database not available - cannot save chat")
        return False
    try:
        chat_entry = {
            "user_id": str(user_id),  # Always store as string
            "message": message,
            "sender": sender,  # "user" or "bot"
            "timestamp": datetime.utcnow()
        }
        result = await db.chat_history.insert_one(chat_entry)
        return True
    except Exception as e:
        print(f"Error saving chat: {str(e)}")
        return False

async def get_chat_history(user_id):
    """Retrieve chat history for a specific user."""
    if db is None:
        print("Database not available - cannot retrieve chat history")
        return []
    try:
        user_id_str = str(user_id)
        query = {"user_id": user_id_str}
        
        chats = await db.chat_history.find(query).sort("timestamp", 1).to_list(None)
        
        for chat in chats:
            # Convert ObjectId and datetime for JSON serialization
            chat['_id'] = str(chat['_id'])
            chat['timestamp'] = chat['timestamp'].isoformat() if chat.get('timestamp') else None
        return chats
    except Exception as e:
        print(f"Error retrieving chat history: {str(e)}")
        return []
