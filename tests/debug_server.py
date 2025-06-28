import subprocess
import sys
import socket

def check_processes():
    """Check what's running on port 8000"""
    print("🔍 Checking what's running on port 8000...")
    
    try:
        if sys.platform == "win32":
            # Windows command to check port 8000
            result = subprocess.run(
                ["netstat", "-ano", "|", "findstr", ":8000"], 
                shell=True, 
                capture_output=True, 
                text=True
            )
            if result.returncode == 0 and result.stdout.strip():
                print("✅ Something is running on port 8000:")
                print(result.stdout)
            else:
                print("❌ Nothing found on port 8000")
        else:
            # Linux/Mac command
            result = subprocess.run(
                ["lsof", "-i", ":8000"], 
                capture_output=True, 
                text=True
            )
            if result.returncode == 0 and result.stdout.strip():
                print("✅ Something is running on port 8000:")
                print(result.stdout)
            else:
                print("❌ Nothing found on port 8000")
                
    except Exception as e:
        print(f"❌ Error checking processes: {e}")

def check_uvicorn_processes():
    """Check for uvicorn processes"""
    print("\n🔍 Checking for uvicorn processes...")
    
    try:
        if sys.platform == "win32":
            result = subprocess.run(
                ["tasklist", "/FI", "IMAGENAME eq python.exe", "/FO", "CSV"], 
                capture_output=True, 
                text=True
            )
            if "python.exe" in result.stdout:
                print("✅ Python processes found:")
                lines = result.stdout.strip().split('\n')
                for line in lines[1:]:  # Skip header
                    if 'python.exe' in line.lower():
                        print(f"  {line}")
            else:
                print("❌ No Python processes found")
        else:
            result = subprocess.run(
                ["ps", "aux", "|", "grep", "uvicorn"], 
                shell=True,
                capture_output=True, 
                text=True
            )
            if result.stdout.strip():
                print("✅ Uvicorn processes found:")
                print(result.stdout)
            else:
                print("❌ No uvicorn processes found")
                
    except Exception as e:
        print(f"❌ Error checking uvicorn processes: {e}")

def simple_socket_test():
    """Simple socket test to check port 8000"""
    print("\n🔌 Testing socket connection to localhost:8000...")
    
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        result = sock.connect_ex(('localhost', 8000))
        sock.close()
        
        if result == 0:
            print("✅ Socket connection successful - port 8000 is open")
            return True
        else:
            print(f"❌ Socket connection failed - error code: {result}")
            return False
    except Exception as e:
        print(f"❌ Socket test error: {e}")
        return False

if __name__ == "__main__":
    print("🔧 Debugging FastAPI Server Connection\n")
    
    check_processes()
    check_uvicorn_processes()
    socket_works = simple_socket_test()
    
    print("\n📋 Summary:")
    if socket_works:
        print("✅ Port 8000 is accessible")
        print("💡 Try running: python tests/test.py")
        print("💡 Or check: http://localhost:8000 in your browser")
    else:
        print("❌ Port 8000 is not accessible")
        print("💡 Make sure to start your server with:")
        print("   uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000")
        print("💡 Or try:")
        print("   python -m uvicorn backend.main:app --reload")
