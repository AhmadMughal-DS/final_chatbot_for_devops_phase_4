from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import time
import random
import string

# Setup browser
driver = webdriver.Chrome(service=Service(ChromeDriverManager().install()))

def generate_random_email():
    """Generate a random email to avoid conflicts"""
    random_string = ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))
    return f"test_{random_string}@example.com"

try:
    # Open your FastAPI frontend (assuming it's running)
    driver.get("http://localhost:8000")
    
    # Wait for page to load
    time.sleep(2)
    
    # Click on Sign Up button from the home page
    signup_button = driver.find_element(By.CLASS_NAME, "signup")
    signup_button.click()
    
    # Wait for signup page to load
    time.sleep(2)
    
    # Generate random email and password
    test_email = generate_random_email()
    test_password = "testpass123"
    
    # Fill the signup form
    driver.find_element(By.ID, "email").send_keys(test_email)
    driver.find_element(By.ID, "password").send_keys(test_password)
    
    # Click submit button
    submit_button = driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
    submit_button.click()
    
    # Wait for response
    time.sleep(3)
    
    # Check if we're redirected to signin page (successful signup)
    current_url = driver.current_url
    print(f"Current URL after signup attempt: {current_url}")
    
    if "/signin" in current_url:
        print("✅ Signup successful - redirected to signin page")
        print(f"Test account created: {test_email}")
        
        # Now test login with the newly created account
        print("Testing login with new account...")
        driver.find_element(By.ID, "email").send_keys(test_email)
        driver.find_element(By.ID, "password").send_keys(test_password)
        
        submit_button = driver.find_element(By.CSS_SELECTOR, "button[type='submit']")
        submit_button.click()
        
        time.sleep(3)
        
        if "/welcome" in driver.current_url:
            print("✅ Login with new account successful!")
            assert "Welcome" in driver.page_source
        else:
            print("❌ Login with new account failed")
            
    else:
        print(f"⚠️ Unexpected redirect after signup: {current_url}")
        print("Page source preview:", driver.page_source[:200])

except Exception as e:
    print(f"Test failed with error: {str(e)}")
    print(f"Current URL: {driver.current_url}")
    print("Page source preview:", driver.page_source[:500])

finally:
    # Close browser
    driver.quit()
