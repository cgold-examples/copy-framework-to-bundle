#include <iostream>

int boo();
int baz();

int main()
{
  std::cout << "Hello foo" << std::endl;
  std::cout << "Hello boo: " << boo() << std::endl;
  std::cout << "Hello baz: " << baz() << std::endl;
}
