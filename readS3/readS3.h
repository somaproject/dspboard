
#include <map>
#include <string>
#include <sstream>
#include <fstream>
#include <iomanip>

typedef std::map<int, unsigned char> memword;

typedef std::map<unsigned int, memword > memarray;

typedef std::map<unsigned int, unsigned long long int> memseg; 



class readS3 {
  memarray memory;
  unsigned int stringhex(std::string inputs); 
  int readfile(std::string filename, int pos); 
  
public:
  readS3(void); 
  int load(std::string filename); 
  long unsigned int readword(); 
  
  memseg range(int low, int high); 

};
