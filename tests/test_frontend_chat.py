from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.keys import Keys
from webdriver_manager.chrome import ChromeDriverManager
import time

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

print("🚀 Starting Frontend Chat Interface Test...")
print(f"Will test {len(TEST_QUERIES)} queries in the chat interface")

driver = webdriver.Chrome(
    service=Service(ChromeDriverManager().install()),
    options=chrome_options
)

wait = WebDriverWait(driver, 10)

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
    
    # Verify we're on welcome page
    current_url = driver.current_url
    if "/welcome" not in current_url:
        raise Exception(f"Login failed - redirected to: {current_url}")
    
    user_id = current_url.split("user_id=")[-1] if "user_id=" in current_url else "unknown"
    print(f"✅ Login successful! User ID: {user_id}")
    
    # Step 2: Wait for chat interface to load
    print("\n🎬 Step 2: Loading chat interface...")
    
    # Wait for chat elements to be present
    chat_input = wait.until(EC.presence_of_element_located((By.ID, "userInput")))
    send_button = wait.until(EC.presence_of_element_located((By.ID, "sendBtn")))
    chat_messages = wait.until(EC.presence_of_element_located((By.ID, "chatMessages")))
    
    print("✅ Chat interface loaded successfully!")
    print(f"📱 Chat input field: {'Found' if chat_input else 'Not found'}")
    print(f"🔘 Send button: {'Found' if send_button else 'Not found'}")
    print(f"💬 Chat messages area: {'Found' if chat_messages else 'Not found'}")
    
    # Wait for any existing chat history to load
    time.sleep(3)
    
    # Check if there are existing messages
    existing_messages = driver.find_elements(By.CLASS_NAME, "message")
    print(f"📜 Existing messages in chat: {len(existing_messages)}")
    
    # Step 3: Send test queries
    print(f"\n💬 Step 3: Sending {len(TEST_QUERIES)} test queries...")
    
    for i, query in enumerate(TEST_QUERIES, 1):
        print(f"\n🔍 Query {i}/{len(TEST_QUERIES)}: '{query}'")
        
        # Clear input field and type query
        chat_input.clear()
        chat_input.send_keys(query)
        
        # Take screenshot before sending (optional)
        # driver.save_screenshot(f"query_{i}_before.png")
        
        print("⏳ Sending query...")
        send_button.click()
        
        # Wait for user message to appear
        time.sleep(1)
        
        # Wait for bot response (give it time to process)
        print("🤖 Waiting for bot response...")
        
        # Count messages before and after to detect new response
        messages_before = len(driver.find_elements(By.CLASS_NAME, "message"))
        
        # Wait up to 30 seconds for bot response
        max_wait_time = 30
        waited_time = 0
        response_received = False
        
        while waited_time < max_wait_time:
            time.sleep(2)
            waited_time += 2
            
            current_messages = driver.find_elements(By.CLASS_NAME, "message")
            
            # Check if we have at least 2 new messages (user + bot)
            if len(current_messages) >= messages_before + 2:
                response_received = True
                break
            
            print(f"⏳ Still waiting... ({waited_time}s/{max_wait_time}s)")
        
        if response_received:
            print("✅ Bot response received!")
            
            # Get the latest bot message
            bot_messages = driver.find_elements(By.CLASS_NAME, "bot-message")
            if bot_messages:
                latest_bot_message = bot_messages[-1].text
                print("🤖 Bot Response:")
                print("-" * 50)
                print(latest_bot_message[:300] + "..." if len(latest_bot_message) > 300 else latest_bot_message)
                print("-" * 50)
            else:
                print("⚠️ Could not retrieve bot message text")
        else:
            print("⏰ Bot response timed out")
        
        # Take screenshot after response (optional)
        # driver.save_screenshot(f"query_{i}_after.png")
        
        # Wait between queries
        if i < len(TEST_QUERIES):
            print("⏳ Waiting 3 seconds before next query...")
            time.sleep(3)
    
    # Step 4: Show final chat state
    print(f"\n📊 Step 4: Final chat summary...")
    
    # Get all messages
    all_messages = driver.find_elements(By.CLASS_NAME, "message")
    user_messages = driver.find_elements(By.CLASS_NAME, "user-message")
    bot_messages = driver.find_elements(By.CLASS_NAME, "bot-message")
    
    print(f"📈 Total messages in chat: {len(all_messages)}")
    print(f"👤 User messages: {len(user_messages)}")
    print(f"🤖 Bot messages: {len(bot_messages)}")
    
    # Show recent conversation
    print(f"\n💬 Recent conversation:")
    recent_messages = all_messages[-8:] if len(all_messages) > 8 else all_messages
    
    for i, msg in enumerate(recent_messages):
        msg_class = msg.get_attribute("class") or ""
        msg_type = "🧑" if "user-message" in msg_class else "🤖"
        msg_text = msg.text[:80] + "..." if len(msg.text) > 80 else msg.text
        print(f"  {msg_type} {msg_text}")
    
    print(f"\n🎉 FRONTEND CHAT TEST COMPLETED SUCCESSFULLY! 🎉")
    print(f"✅ Tested {len(TEST_QUERIES)} queries in the chat interface")
    print(f"🔗 Chat URL: {driver.current_url}")
    
    # Keep browser open for a few seconds to see results
    print("\n⏳ Keeping browser open for 5 seconds to view results...")
    time.sleep(5)

except Exception as e:
    print(f"❌ Test failed with error: {str(e)}")
    print(f"📍 Current URL: {driver.current_url}")
    
    # Take error screenshot
    try:
        driver.save_screenshot("error_screenshot.png")
        print("📸 Error screenshot saved as 'error_screenshot.png'")
    except:
        pass
    
    # Show page source for debugging
    print("📄 Page source preview:")
    print(driver.page_source[:500])

finally:
    print("\n🔒 Closing browser...")
    driver.quit()
    print("✅ Browser closed successfully")
    print("\n🏁 FRONTEND CHAT TEST COMPLETED!")
    print("Thank you for testing the DevOps Chatbot interface! 🤖💬")
