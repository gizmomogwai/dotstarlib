directory "out"

file "out/dotstar" => ["src/main/cpp/main.cpp", "src/lib/cpp/dotstarlib.h", "out"] do
  sh "g++ -std=c++11 -o out/dotstar -Isrc/lib/cpp src/main/cpp/main.cpp"
end

task :default => "out/dotstar"
