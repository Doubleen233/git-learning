#include <iostream>

// A+B Problem
// 思路：用 long long 读入两个整数，直接输出和，避免 int 溢出。

int main() {
    long long a = 0;
    long long b = 0;
    std::cin >> a >> b;
    std::cout << (a + b) << std::endl;
    return 0;
}
