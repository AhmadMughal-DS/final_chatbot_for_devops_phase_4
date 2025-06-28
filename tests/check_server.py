import requests
import time
import socket

def check_port(host, port):
    """Check if a port is open"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(2)
        result = sock.connect_ex((host, port))
        sock.close()
        return result == 0
    except:
        return False

def check_server():
    """Check if FastAPI server is running"""
    print("🔍 Checking if FastAPI server is running...")
    
    # First check if port 8000 is open
    print("� Checking if port 8000 is open...")
    if not check_port('localhost', 8000):
        print("❌ Port 8000 is not open!")
        print("💡 Make sure your FastAPI server is running on port 8000")
        return False
    else:
        print("✅ Port 8000 is open")
    
    # Try different URLs and methods
    urls_to_try = [
        "http://localhost:8000",
        "http://127.0.0.1:8000",
        "http://localhost:8000/docs",  # FastAPI docs endpoint
    ]
    
    for url in urls_to_try:
        try:
            print(f"🌐 Trying {url}...")
            response = requests.get(url, timeout=10)
            
            print(f"📊 Response status: {response.status_code}")
            print(f"📏 Response length: {len(response.text)} characters")
            
            if response.status_code == 200:
                print(f"✅ FastAPI server is running at {url}!")
                
                # Check if it looks like HTML (your frontend)
                if "<html" in response.text.lower():
                    print("🌐 Server is serving HTML content (frontend)")
                else:
                    print("📄 Server response (first 200 chars):")
                    print(response.text[:200])
                
                return True
            elif response.status_code in [301, 302, 307, 308]:
                print(f"🔄 Server redirected (status {response.status_code})")
                if 'location' in response.headers:
                    print(f"➡️ Redirect location: {response.headers['location']}")
                return True
            else:
                print(f"⚠️ Server responded with status: {response.status_code}")
                print(f"📄 Response: {response.text[:200]}")
                
        except requests.exceptions.ConnectionError as e:
            print(f"❌ Connection error for {url}: {e}")
            continue
        except requests.exceptions.Timeout as e:
            print(f"⏰ Timeout for {url}: {e}")
            continue
        except Exception as e:
            print(f"❌ Error checking {url}: {e}")
            continue
    
    print("❌ Could not connect to FastAPI server!")
    print("\n🔧 Troubleshooting steps:")
    print("1. Make sure you're running the server with:")
    print("   uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000")
    print("2. Or try:")
    print("   python -m uvicorn backend.main:app --reload --port 8000")
    print("3. Check if there are any error messages in the server terminal")
    print("4. Try accessing http://localhost:8000 in your browser")
    
    return False

if __name__ == "__main__":
    server_running = check_server()
    
    if server_running:
        print("\n🚀 Server is ready for testing!")
        print("You can now run your Selenium tests:")
        print("   python tests/test.py")
        print("   python tests/test_signup.py")
        print("   python tests/test_suite.py")
    else:
        print("\n🛑 Please start the FastAPI server before running tests.")
        print("\n💡 If the server is running but this check fails:")
        print("   - Try running the test anyway: python tests/test.py")
        print("   - Check if you can access http://localhost:8000 in your browser")
