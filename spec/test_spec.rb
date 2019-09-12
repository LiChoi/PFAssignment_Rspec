require 'selenium-webdriver'
require 'rspec'
require 'page'

#global variables I'll need in all the methods, blocks etc used in this test
#unlike javascript, a local variable declared outside a function (but in same scope) will not be seen inside the function  
$randomEmail = "#{rand(1000000000)}@gmail.com"
$emails = [$randomEmail, "pewpew@hotmail.com", "talosPrinciple@hotmail.com", "next@gmail.com", "marthaTalks@gmail.com", "pingu95@yahoo.com", "mona_lisa@gmail.com", "CommanderShepard@gmail.com"]  
$password = "password" #password to use to create new account 
$validEmail = "happy@hotmail.com" #Manually created valid account used for testing 
$validPW =  "happy" #Valid password for valid happy@hotmail.com account 
$validName = "Happy Feet" #valid name for the valid account 
$validEmailUpCase = $validEmail.upcase #Used later for testing
$validPWUpCase = $validPW.upcase #Used later for testing

#For Rspec, I'm not going to call the procs in :assert as it's better to do these tests in a separate describe block 
$testCases = [
        {
            case: "Test if valid email and valid password allows login",
            email: $validEmail,
            password: $validPW,
            expect: "logged in"
        },
        {
            case: "Test if valid email and invalid password allows login",
            email: $validEmail,
            password: "wrongPW",
            expect: "unable to login",
            assert: Proc.new {|driver|
                puts "Test if error message displays when login fails"
                testPass = true
                begin
                    Page.find[:login][:alert].call(driver)
                rescue 
                    testPass = false;
                    puts "Test failed: error message does not appear when login fails"
                end
                puts "Test passed: error message displays when login fails" if testPass
            }
        },
        {
            case: "Test if wrong email tag allows login",
            email: "happy@gmail.com",
            password: $validPW,
            expect: "unable to login"
        },
        {
            case: "Test case sensitivity of email using valid login credentials",
            email: $validEmailUpCase,
            password: $validPW,
            expect: "logged in"
        },
        {
            case: "Test case sensitivity of password using valid email and uppercase pw",
            email: $validEmail,
            password: $validPWUpCase,
            expect: "unable to login"
        },
        {
            case: "Test if empy email allows login",
            email: "empty",
            password: $validPW,
            expect: "unable to login"
        },
        {
            case: "Test if empty password allows login",
            email: $validEmail,
            password: "empty",
            expect: "unable to login"
        },
        {
            case: "Test if empy email and empty password allows login by clicking login",
            email: "empty",
            password: "empty",
            expect: "unable to login"
        },
        {
            case: "Test SQL injection attack in email field",
            email: "xxx@xxx.xxx' OR 1 = 1 LIMIT 1 -- ' ]",
            password: $validPW,
            expect: "unable to login"
        },
        {
            case: "Test SQL injection attack into password field",
            email: $validEmail,
            password: "password' OR 1=1",
            expect: "unable to login"
        },
        {
            #I'm not concerned about inserting iframe into login field, but if this were a comment field
            #then database could serve up iframe and/or script to other users if field not sanitized
            case: "Test cross-scripting vulnerability",
            email: 'N"> == $0 <iframe src="http:\/\/www.hotmail.com" class="box"></iframe><input type="text', 
            password: "<script>let i = 0; do{i++}while(true);</script>",      
            expect: "unable to login",
            assert: Proc.new {|driver|
                input = Page.find[:login][:email].call(driver).attribute("value")
                puts input.match(/[<>=]+/) ? "Secondary test failed: input not sanitized, dangerous characters remain" : "Secondary test passed: dangerous characters sanitized"
            } 
        }
    ]

#helper functions that will be called in each example test 
def getLoginPage(driver)
    driver.navigate.to Page.find[:URL][:home]
    Page.find[:topBar][:login].call(driver).click
end

def signOut(driver) 
    Page.find[:topBar][:logout].call(driver).click
end

def validSignIn(driver) 
    Page.find[:login][:email].call(driver).send_keys $validEmail
    Page.find[:login][:passwd].call(driver).send_keys $validPW
    Page.find[:login][:submitLogin].call(driver).click
end

#not real test cases, just me playing around with rspec to learn it 
=begin
describe Page do
    it "Test if I set up page.rb correctly so that I can import class Page and access the find object inside it" do 
        homeURL = Page.find[:URL][:home]
        expect(homeURL).to eq "http://automationpractice.com/index.php"
    end  
end

describe Page do
    it "Test if I can successfully enter login page and get the title using selenium and then test with rspec" do
        driver = Selenium::WebDriver.for :firefox
        getLoginPage(driver)
        title = driver.title
        expect(title).to eq Page.find[:login][:title]
        driver.quit 
    end
end
=end

=begin
class Car 
    def say 
        "Tesla"
    end
end

car = "Tesla"
cars = {car: car}

def getCar
    "Tesla"
end


describe Car do
   before(:each) do
        @car = 'Tesla'                #after experimenting, it seems @instance declarations within describe block behave like @instance declarations in classes 
   end
    
    it "testing" do
        
        expect(@car).to eq "Tesla"
    end
end

=end

=begin
describe "testing why code that occurs after loop executes before loop is finished" do
    driver = Selenium::WebDriver.for :firefox
    count = 0
    5.times do 
        it "Can something declared outside of it block exist inside it block" do
            #count += 1  #putting count++ in here causes count to count up with each it block
            puts "Within loop and within it block. The loop count is:"
            puts count   #triple lol! if counting up outside it block but within the loop, the count is already 5 by the time the first loop executes. 
            getLoginPage(driver)
            title = driver.title
            expect(title).to eq Page.find[:login][:title]
            driver.navigate.back
        end
        count += 1  #putting count++ here, count is incremented with each loop before any of the it blocks execute 
        puts "Within loop but outside it block. The count is: #{count}"
    end
    puts "I should print after loop is done and count is 5. The count is: #{count}" if count >= 5 #lol somehow count is 5 (and thus is printed to console) before the first loop even begins... what sorcery is this?? 
end  #so it's clear at this point that it blocks are generated and run asynchronously, at least with respect to the other parts of the code. It blocks seems to execute in order wrt each other   
=end

#=begin
describe Page do 
    context "Testing various login credentials to see if can sign in" do
        before(:all) do 
            @driver = Selenium::WebDriver.for :firefox
            getLoginPage(@driver)
            #count = 0
        end 
    
        $testCases.each do |x|
            it "#{x[:case]}, expect: #{x[:expect]}" do
                #count += 1
                puts "#{x[:case]}, Email: #{x[:email]}, password: #{x[:password]}"
                Page.find[:login][:email].call(@driver).send_keys x[:email] if x[:email] != "empty"
                Page.find[:login][:passwd].call(@driver).send_keys x[:password] if x[:password] != "empty"
                Page.find[:login][:submitLogin].call(@driver).click
                title = @driver.title
                expect(title).to eq Page.find[:account][:title] if x[:expect] == "logged in"
                expect(title).not_to eq Page.find[:account][:title] if x[:expect] == "unable to login"
                Page.find[:topBar][:logout].call(@driver).click if title == Page.find[:account][:title]
                Page.find[:login][:email].call(@driver).clear
                Page.find[:login][:passwd].call(@driver).clear
                #driver.quit if count == $testCases.count #this hack is needed to make sure driver closes browser AFTER all cases have been tested and NOT BEFORE!
            end #close it 
        end #close do each 
        #driver.quit  #hmm... rspec is executing this before the loop even begins. why?
        after(:all) do 
            @driver.quit   #this is the proper way to close driver after all examples, using before and after hooks (instead of hacking it with count)
        end 
    end #close context 
end
#=end

#=begin
describe Page do
    before(:each) do
        @driver = Selenium::WebDriver.for :firefox
        getLoginPage(@driver)
    end
    it "should not allow me to access my account after logging out by posting URL to my account" do
        validSignIn(@driver)
        signOut(@driver)
        @driver.navigate.to Page.find[:URL][:home]
        title = @driver.title
        expect(title).not_to eq Page.find[:account][:title]
    end
    after(:each) do
        @driver.quit
    end
end
#=end

#=begin
describe Page do
    before(:each) do  
        @driver = Selenium::WebDriver.for :firefox  #if declare driver as local variable, it will not be visible inside it block. Declaring as instance variable seems to work as if the entire describe block behaves like the inside of a class 
        getLoginPage(@driver) 
    end 
    it "should not allow multi-login attempt" do
        Page.find[:login][:email].call(@driver).send_keys $validEmail
        5.times do 
            Page.find[:login][:passwd].call(@driver).send_keys rand(100)
            Page.find[:login][:submitLogin].call(@driver).click
        end
        Page.find[:login][:passwd].call(@driver).clear
        Page.find[:login][:passwd].call(@driver).send_keys $validPW
        Page.find[:login][:submitLogin].call(@driver).click
        title = @driver.title
        expect(title).not_to eq Page.find[:account][:title]  #if this test passes, code after it will run. But if it fails, any code after it will not run, hence the need to add before and after hooks to set up and tear down tests
    end
    after(:each) do 
        signOut(@driver)
        @driver.quit 
    end 
end
#=end

#=begin
describe Page do
    before(:each) do
        @driver = Selenium::WebDriver.for :firefox
        getLoginPage(@driver)
    end

    it "should not allow password to be copied and pasted" do
        elem = Page.find[:login][:passwd].call(@driver)
        elem.send_keys "CopyMe"
        elem.send_keys [:control, 'a']
        elem.send_keys [:control, 'c']
        elem2 = Page.find[:login][:email].call(@driver)
        elem2.send_keys [:control, 'v']
        elem2.send_keys [:enter]
        input = elem2.attribute("value")
        expect(input).not_to eq "CopyMe"
    end

    after(:each) do
        @driver.quit
    end
end
#=end

#=begin
describe Page do
    before(:each) do
        @driver = Selenium::WebDriver.for :firefox
        getLoginPage(@driver)
    end

    it "should not allow me to sign back in after signing out by pressing back button" do
        elem = Page.find[:login][:passwd].call(@driver)
        elem.send_keys $validPW
        elem.send_keys :enter  
        sleep(2) 
        elem2 = Page.find[:login][:email].call(@driver)
        elem2.send_keys $validEmail
        elem2.send_keys :enter
        sleep(2) 
        signOut(@driver)
        sleep(2) 
        @driver.navigate.back
        @driver.navigate.back
        sleep(2) 
        input = Page.find[:login][:passwd].call(@driver).attribute("value")
        expect(input).not_to eq $validPW
    end

    after(:each) do
        @driver.quit 
    end
end
#=end

#=begin
describe Page do
    before(:each) do
        @driver = Selenium::WebDriver.for :firefox
        getLoginPage(@driver)
    end

    it "should not allow me to sign-in by opening a new browser while I'm already signed in" do
        validSignIn(@driver) 
        @driver2 = Selenium::WebDriver.for :firefox
        @driver2.navigate.to Page.find[:URL][:home]
        loggedIn = true 
        begin
            Page.find[:topBar][:account].call(@driver2)
        rescue
            loggedIn = false
        end
        expect(loggedIn).to eq true 
    end

    after(:each) do
        signOut(@driver)
        @driver.quit
        @driver2.quit
    end
end
#=end







