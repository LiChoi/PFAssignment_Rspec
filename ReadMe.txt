For rspec to recognize your test files, these file names must end with '_spec.rb'
Attempting to run '_spec.rb' files normally by typing .\file_spec.rb will cause error as ruby will not recognize _spec.rb 

To run ALL _spec.rb files inside a folder, name the folder spec, then type into command line: 'rspec spec' 

To run one specific _spec.rb file inside spec folder, type: 'rspec spec\filename_spec.rb' 

You can also run a specific _spec.rb file by going into spec folder and typing 'rspec filename_spec.rb', but this might not work if filename_spec.rb requires external file 
