#include <cstdlib>
#include <iostream>

int main() {
    const char* mode = std::getenv("MODE");

    std::cout << "KT10 build successfully started" << std::endl;
    std::cout << "MODE=" << (mode ? mode : "NOT_SET") << std::endl;
    return 0;
}
