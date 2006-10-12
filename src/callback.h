#ifndef CALLBACK_H
#define CALLBACK_H

class CallbackBase
{
public:
  virtual void operator()() const {}; 
  virtual ~CallbackBase()= 0; 
}; 

CallbackBase::~CallbackBase() { }; 

template < class T  >
class Callback: public CallbackBase
{
public:
  typedef void (T::*Func) (); 
  
  Callback(T& t, Func func) : object(&t), f(func) {} 
  void operator()() const { (object->*f)(); }
  
private:
  T* object;
  Func f; 
};


#endif // CALLBACK_H
