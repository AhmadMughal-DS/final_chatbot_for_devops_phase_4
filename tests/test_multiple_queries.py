from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
import time
import requests
import json

# Setup Chrome options
chrome_options = Options()
chrome_options.add_argument("--disable-web-security")
chrome_options.add_argument("--disable-features=VizDisplayCompositor")
chrome_options.add_argument("--disable-logging")
chrome_options.add_argument("--log-level=3")
chrome_options.add_argument("--silent")

# Test queries to run
TEST_QUERIES = [
    "Who is Qasim Malik?",
    "What is DevOps?",
    "Explain Docker containers",
    "What is CI/CD pipeline?"
]

# Test credentials
TEST_EMAIL = "ahmadzafar392@gmail.com"
TEST_PASSWORD = "123"

print("🚀 Starting Comprehensive Chatbot Test...")
driver = webdriver.Chrome(
    service=Service(ChromeDriverManager().install()),
    options=chrome_options
)

user_id = None

try:
    # Step 1: Login
    print("\n📡 Step 1: Logging into the application...")
    driver.get("http://localhost:8000")
    time.sleep(2)
    
    # Navigate to signin
    signin_button = driver.find_element(By.CLASS_NAME, "signin")
    signin_button.click()
    time.sleep(2)
    
    # Login
    driver.find_element(By.ID, "email").send_keys(TEST_EMAIL)
    driver.find_element(By.ID, "password").send_keys(TEST_PASSWORD)
    submit_button = driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
    submit_button.click()
    time.sleep(3)
    
    # Extract user_id
    current_url = driver.current_url
    if "/welcome" in current_url and "user_id=" in current_url:
        user_id = current_url.split("user_id=")[-1]
        print(f"✅ Login successful! User ID: {user_id}")
    else:
        raise Exception("Login failed")
    
    # Step 2: Test multiple queries via API
    print(f"\n🤖 Step 2: Testing {len(TEST_QUERIES)} chatbot queries...")
    chatbot_url = "http://localhost:8000/ask-devops-doubt"
    
    results = []
    
    for i, query in enumerate(TEST_QUERIES, 1):
        print(f"\n📤 Query {i}/{len(TEST_QUERIES)}: '{query}'")
        
        payload = {
            "user_id": user_id,
            "message": query
        }
        
        try:
            # Send query to chatbot
            print("⏳ Sending to AI chatbot...")
            response = requests.post(
                chatbot_url,
                json=payload,
                headers={"Content-Type": "application/json"},
                timeout=30
            )
            
            if response.status_code == 200:
                response_data = response.json()
                bot_response = response_data.get("response", "No response received")
                
                print(f"✅ Response received ({len(bot_response)} characters)")
                print("🤖 Bot Response:")
                print("=" * 60)
                print(bot_response)
                print("=" * 60)
                
                results.append({
                    "query": query,
                    "response": bot_response,
                    "status": "success"
                })
                
            else:
                error_msg = f"API Error: {response.status_code} - {response.text}"
                print(f"❌ {error_msg}")
                results.append({
                    "query": query,
                    "response": error_msg,
                    "status": "error"
                })
                
        except requests.exceptions.Timeout:
            timeout_msg = "Request timed out (AI processing took too long)"
            print(f"⏰ {timeout_msg}")
            results.append({
                "query": query,
                "response": timeout_msg,
                "status": "timeout"
            })
            
        except Exception as e:
            error_msg = f"Error: {str(e)}"
            print(f"❌ {error_msg}")
            results.append({
                "query": query,
                "response": error_msg,
                "status": "error"
            })
        
        # Wait between queries to avoid overwhelming the API
        if i < len(TEST_QUERIES):
            print("⏳ Waiting 2 seconds before next query...")
            time.sleep(2)
    
    # Step 3: Check chat history
    print(f"\n📜 Step 3: Checking chat history...")
    history_url = f"http://localhost:8000/chat-history?user_id={user_id}"
    
    try:
        history_response = requests.get(history_url, timeout=10)
        if history_response.status_code == 200:
            history_data = history_response.json()
            chat_history = history_data.get("history", [])
            
            print(f"✅ Chat history retrieved: {len(chat_history)} total messages")
            
            # Show recent messages
            if chat_history:
                print("\n📝 Recent chat messages:")
                recent_messages = chat_history[-8:]  # Last 8 messages (4 queries + 4 responses)
                
                for i, msg in enumerate(recent_messages):
                    sender = msg.get("sender", "unknown")
                    message = msg.get("message", "")
                    timestamp = msg.get("timestamp", "")
                    
                    # Truncate long messages for display
                    display_msg = message[:80] + "..." if len(message) > 80 else message
                    
                    print(f"  {i+1}. [{sender}] {display_msg} ({timestamp})")
            else:
                print("⚠️ No chat history found")
        else:
            print(f"❌ Failed to get chat history: {history_response.status_code}")
            
    except Exception as e:
        print(f"❌ Error checking chat history: {str(e)}")
    
    # Step 4: Display summary
    print(f"\n📊 Step 4: Test Summary")
    print("=" * 70)
    
    successful_queries = len([r for r in results if r["status"] == "success"])
    failed_queries = len([r for r in results if r["status"] in ["error", "timeout"]])
    
    print(f"✅ Successful queries: {successful_queries}/{len(TEST_QUERIES)}")
    print(f"❌ Failed queries: {failed_queries}/{len(TEST_QUERIES)}")
    print(f"👤 User ID: {user_id}")
    print(f"🔗 Welcome URL: http://localhost:8000/welcome?user_id={user_id}")
    
    if successful_queries > 0:
        print("\n🎉 CHATBOT IS WORKING! 🎉")
    else:
        print("\n⚠️ CHATBOT NEEDS ATTENTION ⚠️")
    
    print("\nDetailed Results:")
    for i, result in enumerate(results, 1):
        status_emoji = "✅" if result["status"] == "success" else "❌"
        print(f"{status_emoji} Query {i}: {result['query']}")
        print(f"   Status: {result['status']}")
        if result["status"] == "success":
            response_preview = result["response"][:100] + "..." if len(result["response"]) > 100 else result["response"]
            print(f"   Response: {response_preview}")
        print()
    
except Exception as e:
    print(f"❌ Test failed with error: {str(e)}")
    print(f"📍 Current URL: {driver.current_url}")

finally:
    print("\n🔒 Step 5: Closing browser...")
    time.sleep(3)  # Give user time to see results
    driver.quit()
    print("✅ Browser closed successfully")
    
    print(f"\n🏁 TEST COMPLETED!")
    if user_id:
        print(f"💡 You can continue chatting at: http://localhost:8000/welcome?user_id={user_id}")
    print("Thank you for testing the DevOps Chatbot! 🤖")
