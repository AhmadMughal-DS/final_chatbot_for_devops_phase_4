from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from webdriver_manager.chrome import ChromeDriverManager
import time

# Setup Chrome options for headless mode
chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")
chrome_options.add_argument("--disable-gpu")
chrome_options.add_argument("--window-size=1920,1080")
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

print("🚀 Starting Jenkins Frontend Chat Test...")
print(f"Will test {len(TEST_QUERIES)} queries in headless mode")

driver = webdriver.Chrome(
    service=Service(ChromeDriverManager().install()),
    options=chrome_options
)

wait = WebDriverWait(driver, 15)

try:
    # Step 1: Login
    print("\n📡 Step 1: Logging into the application...")
    driver.get("http://localhost:8000")
    time.sleep(3)
    
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
    
    chat_input = wait.until(EC.presence_of_element_located((By.ID, "userInput")))
    send_button = wait.until(EC.presence_of_element_located((By.ID, "sendBtn")))
    
    print("✅ Chat interface loaded successfully!")
    time.sleep(3)
    
    # Step 3: Send test queries
    print(f"\n💬 Step 3: Sending {len(TEST_QUERIES)} test queries...")
    
    successful_queries = 0
    
    for i, query in enumerate(TEST_QUERIES, 1):
        print(f"\n🔍 Query {i}/{len(TEST_QUERIES)}: '{query}'")
        
        try:
            # Clear and send query
            chat_input.clear()
            chat_input.send_keys(query)
            send_button.click()
            time.sleep(2)
            
            # Wait for response (shorter timeout for CI)
            print("🤖 Waiting for bot response...")
            time.sleep(15)  # Wait 15 seconds for response
            
            # Check if response was received
            bot_messages = driver.find_elements(By.CLASS_NAME, "bot-message")
            if bot_messages:
                latest_response = bot_messages[-1].text
                if latest_response and len(latest_response) > 10:
                    print("✅ Bot response received!")
                    print(f"Response preview: {latest_response[:100]}...")
                    successful_queries += 1
                else:
                    print("⚠️ Empty or very short response")
            else:
                print("⚠️ No bot response detected")
                
        except Exception as e:
            print(f"❌ Query {i} failed: {str(e)}")
        
        # Wait between queries
        if i < len(TEST_QUERIES):
            time.sleep(3)
    
    # Final results
    print(f"\n📊 Test Results:")
    print(f"✅ Successful queries: {successful_queries}/{len(TEST_QUERIES)}")
    print(f"📈 Success rate: {(successful_queries/len(TEST_QUERIES))*100:.1f}%")
    
    if successful_queries >= len(TEST_QUERIES) * 0.75:  # 75% success rate
        print("🎉 FRONTEND CHAT TEST PASSED!")
        exit(0)
    else:
        print("❌ FRONTEND CHAT TEST FAILED - Low success rate")
        exit(1)

except Exception as e:
    print(f"❌ Test failed with error: {str(e)}")
    print(f"📍 Current URL: {driver.current_url}")
    exit(1)

finally:
    driver.quit()
    print("✅ Browser closed")
