#ifndef DATASINKBASE_H
#define DATASINKBASE_H


class DataSinkBase
{
  void sampleProcess(void) = 0; 
  void onEvent(const Event&) = 0; 

};

#endif // DATASINKBASE_H

