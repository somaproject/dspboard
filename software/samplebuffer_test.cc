


#include "samplebuffer.h"
#include <iostream>


using namespace std; 

int main() {


  cout << "Hello World" << endl;
  
  SampleBuffer<int, 10> sb; 
  sb.append(1); 
  sb.append(2); 
  sb.append(3); 
  
  for (int i = 0; i < 10; i++){
    cout << sb[i] << ' '; 
  }
  cout << endl; 

  
}
