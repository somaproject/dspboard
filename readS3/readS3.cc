#include <iostream>
#include <map>
#include <vector>
#include <string>
#include <sstream>
#include <fstream>
#include "readS3.h"

using namespace std; 

readS3::readS3() {

}

int readS3::load(string filename) {
  
  int i = 0 ; 
  i = readfile(filename+".s_0", 0); 
  if( i )
    return i; 
  
  i = readfile(filename+".s_1", 1); 
  if( i )
    return i; 
  
  i = readfile(filename+".s_2", 2); 
  if( i )
    return i; 
  
  i = readfile(filename+".s_3", 3); 
  if( i )
    return i; 
  
  i = readfile(filename+".s_4", 4); 
  if( i )
    return i; 
  
  i = readfile(filename+".s_5", 5); 
  if( i )
    return i; 

  //validate

  // for each location in memory make sure all bytes are filled in

  memarray::iterator it; 
  for ( it = memory.begin(); it != memory.end(); ++it) {
    memword a = it->second; 
    if(a.count(0) > 0 & 
       a.count(1) > 0 & 
       a.count(2) > 0 & 
       a.count(3) > 0 & 
       a.count(4) > 0 & 
       a.count(5) > 0) {    
      // all necessary bytes!
    } else {
      cout << "Error for word " << it->first << " : not enough bytes" << endl;
      return -3; 
    }
    
   }

  return 0; 

}
  

unsigned int readS3::stringhex(string inputs) {
  // takes in a hex string, figures out the hex value, returns that
  
  istringstream ins; 
  ins.str(inputs);
  
  unsigned int output; 
  ins >> hex >> output; 
  return output; 

}

int readS3::readfile(string filename, int pos) {
  
  ifstream  hexfile;
  hexfile.open(filename.c_str()); 
  if (! hexfile){ 
    cerr << "Problem opening " << filename << endl;
    return -2;
  }
  
 
  string record; 
  while(! hexfile.eof()) {
    getline(hexfile, record); 

    
    if(record.substr(0,2) == "S3") {
      int len = stringhex(record.substr(2,2)) -( 4+1);
      unsigned int addr = stringhex(record.substr(4, 8)); 

      for (int i = 0; i < len; i++) {
	memory[addr][pos] = stringhex(record.substr(12+i*2, 2));
	addr++; 
      }
    } else if (record.substr(0,2) == "S0") {
      // beginnning of file
    } else if (record.substr(0,2) == "S7") {
      // end of file
      break; 
    } else {
      cerr << "malformed file " << filename << endl; 
      return -1; 
    }
    
    
  }
  return 0; // success!!

}

memseg readS3::range(int low, int high) {
  
  
  memarray  tmpmem(memory.lower_bound(low), 
		    memory.upper_bound(high));

  memseg output; 

  memarray::iterator it; 
  for ( it = tmpmem.begin(); it != tmpmem.end(); ++it) {
   unsigned long long foo(0); 
    
    cout <<(unsigned int)  it->second[5] << ' ';
    cout << (unsigned int) it->second[4] << ' ';
    cout << (unsigned int) it->second[3] << ' ';
    cout << (unsigned int) it->second[2] << ' ';
    cout << (unsigned int) it->second[1] << ' ';
    cout <<(unsigned int)  it->second[0] << endl; 
 

    foo = it->second[5];
    foo = (foo<<8) | it->second[4];
    foo = (foo<<8) | it->second[3];
    foo = (foo<<8) | it->second[2];
    foo = (foo<<8) | it->second[1];
    foo = (foo<<8) | it->second[0];
 

      



    output[it->first] = foo;
  }
  return output; 

}
