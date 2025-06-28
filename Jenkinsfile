pipeline {
    // Use any available agent instead of requiring a specific label
    agent any
    
    environment {
        PROJECT_NAME = 'devops_chatbot_pipeline'
        DOCKER_COMPOSE_FILE = 'docker-compose.yml'
        GITHUB_REPO = 'https://github.com/AhmadMughal-DS/final_chatbot_for_devops_phase_3'
    }
    
    stages {
        stage('Checkout') {
            steps {
                // Clean workspace before we start
                cleanWs()
                
                // Fetch code from GitHub repository
                echo 'Fetching code from GitHub repository'
                sh    """ git clone "${GITHUB_REPO}" """
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building Docker containers'
                // Check Docker and Docker Compose installation
                sh 'docker --version || sudo docker --version'
                sh 'docker-compose --version || sudo docker-compose --version'
                
                // Navigate to the cloned repository directory
                dir('final_chatbot_for_devops_phase_3') {
                    // Build the Docker images with sudo
                    sh '''
                        sudo docker-compose -p ${PROJECT_NAME} -f ${DOCKER_COMPOSE_FILE} build --no-cache
                    '''
                }
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying application with Docker Compose'
                
                // Navigate to the cloned repository directory
                dir('final_chatbot_for_devops_phase_3') {
                    // Stop any existing containers with the same project name
                    sh '''
                        sudo docker-compose -p ${PROJECT_NAME} -f ${DOCKER_COMPOSE_FILE} down || \
                        echo "No existing containers to stop"
                    '''
                    
                    // Start the containers in detached mode
                    sh '''
                        sudo docker-compose -p ${PROJECT_NAME} -f ${DOCKER_COMPOSE_FILE} up -d
                        echo "Deployment complete"
                    '''
                    
                    // Verify that the containers are running
                    sh 'sudo docker-compose -p ${PROJECT_NAME} -f ${DOCKER_COMPOSE_FILE} ps'
                }
            }
        }
        
        stage('Verify') {
            steps {
                echo 'Verifying the deployment'
                // Wait for application to be ready
                sh 'sleep 50'
                
                // Check if the container is running
                sh 'sudo docker ps | grep devops_chatbot || echo "Container not found"'
                
                // Show logs for debugging
                sh 'sudo docker logs devops_chatbot_backend || echo "Could not get container logs"'
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running Frontend Chat Tests'
                
                // Navigate to the cloned repository directory
                dir('final_chatbot_for_devops_phase_3') {
                    // Install Chrome and dependencies for Selenium
                    sh '''
                        # Update package list
                        sudo apt-get update
                        
                        # Install Chrome dependencies
                        sudo apt-get install -y wget gnupg2 software-properties-common
                        
                        # Add Google Chrome repository
                        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
                        echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
                        
                        # Install Google Chrome
                        sudo apt-get update
                        sudo apt-get install -y google-chrome-stable
                        
                        # Install Python dependencies (assuming Python3 and pip3 are already installed)


                        #source venv/bin/activate

                        pip3 install -r requirements.txt --break-system-packages
                        
                        # Install additional dependencies for headless Chrome
                        sudo apt-get install -y xvfb
                    '''
                    
                    // Wait a bit more for the application to be fully ready
                    sh 'sleep 30'
                    
                    // Run the frontend chat test in headless mode
                    sh '''
                        echo "Starting Frontend Chat Test..."
                        
                        # Set display for headless Chrome
                        export DISPLAY=:99
                        Xvfb :99 -screen 0 1024x768x24 &
                        
                        # Wait for Xvfb to start
                        sleep 5
                        
                        # Create a modified version of the test for headless mode
                        cat > tests/test_frontend_chat_headless.py << 'EOF'
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
    print("\\n📡 Step 1: Logging into the application...")
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
    print("\\n🎬 Step 2: Loading chat interface...")
    
    chat_input = wait.until(EC.presence_of_element_located((By.ID, "userInput")))
    send_button = wait.until(EC.presence_of_element_located((By.ID, "sendBtn")))
    
    print("✅ Chat interface loaded successfully!")
    time.sleep(3)
    
    # Step 3: Send test queries
    print(f"\\n💬 Step 3: Sending {len(TEST_QUERIES)} test queries...")
    
    successful_queries = 0
    
    for i, query in enumerate(TEST_QUERIES, 1):
        print(f"\\n🔍 Query {i}/{len(TEST_QUERIES)}: '{query}'")
        
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
    print(f"\\n📊 Test Results:")
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

EOF
                        
                        # Run the test
                        python3 tests/test_frontend_chat_headless.py
                        
                        echo "Frontend Chat Test completed!"
                    '''
                }
            }
        }
        
        stage('Auto-Stop After 5 Minutes') {
            steps {
                echo 'Setting up automatic container shutdown after 5 minutes'
                
                // Navigate to the cloned repository directory
                dir('final_chatbot_for_devops_phase_3') {
                    sh '''
                        echo "Containers will be stopped after 5 minutes..."
                        (sleep 300 && sudo docker-compose -p ${PROJECT_NAME} -f ${DOCKER_COMPOSE_FILE} down) &
                        echo "Auto-stop scheduled!"
                    '''
                }
            }
        }
    }
    
    post {
        always {
            echo 'Cleaning up workspace'
            
            // Show final container status
            sh '''
                echo "Final container status:"
                sudo docker ps | grep devops_chatbot || echo "No chatbot containers running"
            '''
            
            deleteDir() // Clean workspace after build
        }
        success {
            echo '🎉 CI Pipeline completed successfully!'
            echo '✅ All stages passed including frontend tests'
            echo '🚀 Application is deployed and tested'
        }
        failure {
            echo '❌ CI Pipeline failed!'
            echo '🔍 Check the logs above for details'
            
            // Show application logs for debugging
            sh '''
                echo "Application logs for debugging:"
                sudo docker logs devops_chatbot_backend || echo "Could not get backend logs"
            '''
            
            // You can add notification steps here (email, Slack, etc.)
        }
    }
}
