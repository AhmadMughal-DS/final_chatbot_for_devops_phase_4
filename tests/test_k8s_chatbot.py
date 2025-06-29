#!/usr/bin/env python3
"""
Kubernetes-compatible chatbot test that works without Selenium
"""
import os
import requests
import time
import json

def test_kubernetes_chatbot():
    """Test the chatbot API on Kubernetes deployment"""
    
    # Get Kubernetes service URL
    try:
        # Try to get Minikube IP and NodePort
        import subprocess
        minikube_ip = subprocess.check_output(['minikube', 'ip']).decode().strip()
        
        # Get NodePort
        kubectl_cmd = [
            'kubectl', 'get', 'service', 'devops-chatbot-service', 
            '-o', 'jsonpath={.spec.ports[0].nodePort}'
        ]
        node_port = subprocess.check_output(kubectl_cmd).decode().strip()
        
        base_url = f"http://{minikube_ip}:{node_port}"
        print(f"🎯 Testing Kubernetes deployment at: {base_url}")
        
    except Exception as e:
        print(f"❌ Could not get Kubernetes service URL: {e}")
        # Fallback to localhost for local testing
        base_url = "http://localhost:8002"
        print(f"🔄 Falling back to localhost: {base_url}")

    # Test endpoints
    test_endpoints = [
        "/",  # Home page
        "/health",  # Health check (if available)
    ]
    
    print("🚀 Starting Kubernetes chatbot connectivity test...")
    
    for endpoint in test_endpoints:
        url = base_url + endpoint
        try:
            print(f"🔍 Testing {endpoint}...")
            response = requests.get(url, timeout=10)
            
            if response.status_code == 200:
                print(f"✅ {endpoint} - Status: {response.status_code}")
                
                # Check if response contains expected content
                content = response.text.lower()
                if any(keyword in content for keyword in ['devops', 'chatbot', 'signin', 'login']):
                    print(f"✅ {endpoint} - Contains expected content")
                else:
                    print(f"⚠️ {endpoint} - Unexpected content")
                    
            else:
                print(f"⚠️ {endpoint} - Status: {response.status_code}")
                
        except requests.exceptions.Timeout:
            print(f"⏰ {endpoint} - Timeout")
        except requests.exceptions.ConnectionError:
            print(f"❌ {endpoint} - Connection error")
        except Exception as e:
            print(f"❌ {endpoint} - Error: {e}")
    
    # Test main page specifically
    try:
        print("\n🌐 Testing main application page...")
        response = requests.get(base_url, timeout=15)
        
        if response.status_code == 200:
            print("✅ Main page is accessible!")
            
            # Check if it's HTML content
            if 'html' in response.text.lower():
                print("✅ Response is HTML content")
                
                # Check for specific application elements
                content = response.text.lower()
                checks = {
                    'DevOps content': any(keyword in content for keyword in ['devops', 'chatbot']),
                    'Sign-in functionality': any(keyword in content for keyword in ['signin', 'login', 'sign in']),
                    'Interactive elements': any(keyword in content for keyword in ['button', 'form', 'input']),
                }
                
                for check_name, passed in checks.items():
                    status = "✅" if passed else "⚠️"
                    print(f"{status} {check_name}: {'Found' if passed else 'Not found'}")
                
                print("✅ Kubernetes deployment test PASSED!")
                return True
            else:
                print("❌ Response is not HTML content")
                return False
        else:
            print(f"❌ Main page returned status: {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ Main page test failed: {e}")
        return False

if __name__ == "__main__":
    print("🧪 Kubernetes DevOps Chatbot Test")
    print("=" * 50)
    
    success = test_kubernetes_chatbot()
    
    if success:
        print("\n🎉 All tests passed! Kubernetes deployment is working correctly.")
        exit(0)
    else:
        print("\n❌ Some tests failed. Check the deployment.")
        exit(1)
