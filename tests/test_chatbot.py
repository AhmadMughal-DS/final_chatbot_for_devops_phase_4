from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
import time
import requests
import json

# Setup Chrome options to reduce noise and improve stability
chrome_options = Options()
chrome_options.add_argument("--disable-web-security")
chrome_options.add_argument("--disable-features=VizDisplayCompositor")
chrome_options.add_argument("--disable-logging")
chrome_options.add_argument("--log-level=3")
chrome_options.add_argument("--silent")

# Setup browser
print("🚀 Starting Chrome browser for chatbot test...")
driver = webdriver.Chrome(
    service=Service(ChromeDriverManager().install()),
    options=chrome_options
)

# Test user credentials
TEST_EMAIL = "ahmadzafar392@gmail.com"
TEST_PASSWORD = "123"
user_id = None
test_query = "Who is Qasim Malik?"
chatbot_url = "http://localhost:8000/ask-devops-doubt"

try:
    # Step 1: Login to get user_id
    print("📡 Connecting to FastAPI application...")
    driver.get("http://localhost:8000")
    time.sleep(2)
    
    print("🖱️ Navigating to Sign In...")
    signin_button = driver.find_element(By.CLASS_NAME, "signin")
    signin_button.click()
    time.sleep(2)
    
    print("✍️ Logging in...")
    driver.find_element(By.ID, "email").send_keys(TEST_EMAIL)
    driver.find_element(By.ID, "password").send_keys(TEST_PASSWORD)
    submit_button = driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
    submit_button.click()
    time.sleep(3)
    
    # Extract user_id from URL
    current_url = driver.current_url
    if "/welcome" in current_url and "user_id=" in current_url:
        user_id = current_url.split("user_id=")[-1]
        print(f"✅ Login successful! User ID: {user_id}")
    else:
        raise Exception("Login failed - could not extract user_id")
    
    # Step 2: Test chatbot API directly
    print("\n🤖 Testing Chatbot API...")
    
    payload = {
        "user_id": user_id,
        "message": test_query
    }
    
    print(f"📤 Sending query: '{test_query}'")
    print(f"👤 Using user_id: {user_id}")
    
    # Make API request
    response = requests.post(
        chatbot_url,
        json=payload,
        headers={"Content-Type": "application/json"},
        timeout=30  # Give it time to process
    )
    
    print(f"📊 Response status: {response.status_code}")
    
    if response.status_code == 200:
        response_data = response.json()
        bot_response = response_data.get("response", "No response received")
        
        print("✅ Chatbot responded successfully!")
        print(f"🤖 Bot Response:")
        print("-" * 50)
        print(bot_response)
        print("-" * 50)
        
        # Check if response contains relevant information
        if "qasim" in bot_response.lower() or "malik" in bot_response.lower():
            print("✅ Response seems relevant to the query!")
        else:
            print("⚠️ Response might not be specific to Qasim Malik")
            
        # Test chat history
        print("\n📜 Testing chat history...")
        history_url = f"http://localhost:8000/chat-history?user_id={user_id}"
        history_response = requests.get(history_url, timeout=10)
        
        if history_response.status_code == 200:
            history_data = history_response.json()
            chat_history = history_data.get("history", [])
            print(f"✅ Chat history retrieved: {len(chat_history)} messages")
            
            # Show recent messages
            if chat_history:
                print("Recent chat messages:")
                for i, msg in enumerate(chat_history[-4:]):  # Last 4 messages
                    sender = msg.get("sender", "unknown")
                    message = msg.get("message", "")[:100]  # First 100 chars
                    timestamp = msg.get("timestamp", "")
                    print(f"  {i+1}. [{sender}] {message}... ({timestamp})")
            else:
                print("⚠️ No chat history found")
        else:
            print(f"❌ Failed to get chat history: {history_response.status_code}")
            
    else:
        print(f"❌ Chatbot API failed with status: {response.status_code}")
        print(f"Response: {response.text}")
        
    print("\n🎉 Chatbot test completed!")
    
except requests.exceptions.Timeout:
    print("⏰ Chatbot API request timed out - this might be normal for AI processing")
    print("💡 Try increasing the timeout or check server logs")
    
except requests.exceptions.RequestException as e:
    print(f"❌ API request failed: {str(e)}")
    
except Exception as e:
    print(f"❌ Test failed with error: {str(e)}")
    print(f"� Current URL: {driver.current_url}")

finally:
    print("\n🔒 Closing browser...")
    driver.quit()
    print("✅ Browser closed successfully")
    
    # Summary
    if user_id:
        print(f"\n📋 Test Summary:")
        print(f"✅ Login: Success (User ID: {user_id})")
        print(f"🤖 Chatbot Query: '{test_query}'")
        print(f"🔗 API Endpoint: {chatbot_url}")
        print(f"📊 User can test more queries at: http://localhost:8000/welcome?user_id={user_id}")
    else:
        print("\n❌ Test incomplete - login failed")
