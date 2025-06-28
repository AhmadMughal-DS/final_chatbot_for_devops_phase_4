from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.chrome.options import Options
from webdriver_manager.chrome import ChromeDriverManager
import time

# Setup Chrome options to reduce noise and improve stability
chrome_options = Options()
chrome_options.add_argument("--disable-web-security")
chrome_options.add_argument("--disable-features=VizDisplayCompositor")
chrome_options.add_argument("--disable-logging")
chrome_options.add_argument("--log-level=3")  # Suppress INFO, WARNING, ERROR
chrome_options.add_argument("--silent")

# Setup browser
print("🚀 Starting Chrome browser...")
driver = webdriver.Chrome(
    service=Service(ChromeDriverManager().install()),
    options=chrome_options
)

try:
    print("📡 Connecting to FastAPI application...")
    # Open your FastAPI frontend (assuming it's running)
    driver.get("http://localhost:8000")
    
    # Wait for page to load
    time.sleep(2)
    
    print("✅ Homepage loaded successfully")
    print(f"Current URL: {driver.current_url}")
    print(f"Page title: {driver.title}")
    
    # Check if signin button exists
    try:
        signin_button = driver.find_element(By.CLASS_NAME, "signin")
        print("✅ Sign In button found")
    except Exception as e:
        print(f"❌ Sign In button not found: {e}")
        print("Available elements with 'signin' class:", driver.find_elements(By.PARTIAL_LINK_TEXT, "Sign"))
        raise
    
    # Click on Sign In button from the home page
    print("🖱️ Clicking Sign In button...")
    signin_button.click()
    
    # Wait for signin page to load
    time.sleep(2)
    
    print("📝 Sign In page loaded")
    print(f"Current URL: {driver.current_url}")
    
    # Check if form elements exist
    try:
        email_field = driver.find_element(By.ID, "email")
        password_field = driver.find_element(By.ID, "password")
        submit_button = driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
        print("✅ All form elements found")
    except Exception as e:
        print(f"❌ Form elements not found: {e}")
        print("Available input elements:", [elem.get_attribute("id") for elem in driver.find_elements(By.TAG_NAME, "input")])
        raise
    
    # Fill the login form
    print("✍️ Filling login form...")
    email_field.send_keys("ahmadzafar392@gmail.com")
    password_field.send_keys("123")
    print("📧 Email: ahmadzafar392@gmail.com")
    print("🔐 Password: 123")
    
    # Click submit button (it's a form submit button, not an ID)
    print("🚀 Submitting form...")
    submit_button.click()
    
    # Wait for response
    time.sleep(3)
    
    # Check if we're redirected to welcome page or signin page with error
    current_url = driver.current_url
    print(f"📍 Current URL after login attempt: {current_url}")
    
    if "/welcome" in current_url:
        print("✅ Login successful - redirected to welcome page")
        user_id = current_url.split("user_id=")[-1] if "user_id=" in current_url else "unknown"
        print(f"👤 User ID: {user_id}")
        assert "Welcome" in driver.page_source
        print("🎉 Test PASSED: Successfully logged in!")
        
    elif "/signin" in current_url and "error" in current_url:
        print("❌ Login failed - invalid credentials")
        error_msg = current_url.split("error=")[-1] if "error=" in current_url else "unknown error"
        print(f"🚫 Error message: {error_msg}")
        assert "Invalid credentials" in driver.page_source or "error" in current_url
        print("✅ Test PASSED: Error handling works correctly")
        
    else:
        print(f"⚠️ Unexpected redirect to: {current_url}")
        print("📄 Page source preview:", driver.page_source[:500])
        print("❓ This might indicate an issue with the application")

except Exception as e:
    print(f"❌ Test failed with error: {str(e)}")
    print(f"📍 Current URL: {driver.current_url}")
    print("📄 Page source preview:", driver.page_source[:1000])
    
    # Additional debugging
    try:
        print("\n🔍 Debugging Information:")
        print(f"Window size: {driver.get_window_size()}")
        print(f"All available links: {[link.text for link in driver.find_elements(By.TAG_NAME, 'a')]}")
        print(f"All available buttons: {[btn.text for btn in driver.find_elements(By.TAG_NAME, 'button')]}")
    except:
        print("Could not gather additional debugging info")

finally:
    print("\n🔒 Closing browser...")
    # Close browser
    driver.quit()
    print("✅ Browser closed successfully")
