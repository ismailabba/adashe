pragma solidity ^0.5.0;


contract TestAdashe{
  uint public adasheCount = 0;
  
  
  address agent;
 // uint public b = a + 20 seconds;
  //uint public c =  block.timestamp + 20;

   
    //list of adashes available
      //each adashe contains 
      //start date
      //end date
      //amount of people
      //monthly obligations
      //take home pay
      //accounts participants array
    
      struct Adashe {
          uint id;
          string name;
          uint256 startDate;
          uint256 endDate;
          uint noOfPeople;
          uint monthlyObligation;
          uint takeHomePay;
          address[] adasheMembers;
       
 
          

      }
      struct SessionStarted{
          uint adasheId;
          bool inSession;
          uint nextPayment;
          uint currentMonth;
          uint noOfPayed;
          uint noOfCollected;
      }

    
      mapping(uint => Adashe) public adashes;
       mapping(uint => SessionStarted) public session;
      //when each user will collect their   
     // mapping(address => uint256) public paydate;
      mapping(uint => mapping(address => uint)) public paydate;

      mapping(address => mapping(uint => bool)) public monthlyPayment;

      mapping(address => bool) public collected;

     
      mapping(address => mapping(uint => uint)) public deposits;

     
      mapping(uint=> mapping(address => bool)) public joinedAdashe;

      constructor() public {
       //createAdashe("Adashe 1", 1654708484, 1654722884, 3, 100, 300);
      // uint  s = block.timestamp + 10 minutes;
       //SessionStarted(1, true, s);
      }

       //create adashe group - system
      function createAdashe(
        string memory name,
        uint256 startDate, 
        uint256 endDate, 
        uint amountOfPeople, 
        uint monthlyObligation,
        uint takeHomePay
        
       // address[] memory adasheMembers
        
        )
        public {
          adasheCount ++;
          adashes[adasheCount] = Adashe(adasheCount,name,startDate,endDate,amountOfPeople,monthlyObligation,takeHomePay,  new address[](0));
        }

       


        //getter functon for returning array in a sturcut 
        //use adashe id instead of count
        function getAdasheMembers(uint adasheId) public view returns(address[] memory){
          return adashes[adasheId].adasheMembers;

        }


        //oin adahse group - usere6320117E1818faFD3c51A5C303B1c9D76De97d9
        //use adashe id instead of adashecount
        
        
        //change member to msg.sender
        function joinAdasheGroup(uint adasheId, address member) public returns(address[] memory){
          //make sure user can only oin once no dplicate addresses in array
          //user not in other adashe groups
          require(joinedAdashe[adasheId][member] == false, 'user already in adashe group');
          //if noofpeople sorry group full
          require(adashes[adasheId].adasheMembers.length < adashes[adasheId].noOfPeople, 'sorry the group is now full' );
          adashes[adasheId].adasheMembers.push(member);
          joinedAdashe[adasheId][member] = true;

          return adashes[adasheId].adasheMembers;
        }

         //create time/schedule and when everyone collects  
         //use adashe id instead of count b4 deploying
        function scheduleCollection(uint adasheId, uint dayss) public {
          require(adashes[adasheId].adasheMembers.length == adashes[adasheId].noOfPeople);
          uint daysAdded = adashes[adasheId].startDate + dayss;
          for (uint i = 0; i < adashes[adasheId].adasheMembers.length; i++ ){

            //uint timeAdd = i + days;

            //use the startdate instead of start adashe b4 deploying
            paydate[adasheId][adashes[adasheId].adasheMembers[i]] = daysAdded;
            daysAdded = daysAdded + dayss;
          }
          //return paydate[address(0xe6320117E1818faFD3c51A5C303B1c9D76De97d9)];
         

           //return adashes[adasheCount].adasheMembers.length;
         
        }

      

         //pay monthly obligation = system/escrow
         //check paydates
         //update mappimg monthly payment when user pays
         //require it has not reached end date

         //require member is part of the gropip
         
        function pay(uint adasheId, address payer, uint currentMonth, uint dayss, uint monthlyObligation) public payable {
          //make sure user does not pay twice
          require(joinedAdashe[adasheId][payer] == true, 'you have to be in a group');
          require(monthlyPayment[payer][currentMonth] == false, 'you cant pay twice');
          require(block.timestamp > session[adasheId].nextPayment, 'not due yet');
          require(session[adasheId].inSession == true, 'this adashe has not started yet');
          //require(block.timestamp <= adashes[adasheId].endDate);

          
          //increment this month deposit 
          uint amount = monthlyObligation;
          deposits[agent][adasheId] = deposits[agent][adasheId] + amount;


          monthlyPayment[payer][currentMonth] = true;

          if (session[adasheId].noOfPayed == adashes[adasheId].noOfPeople){
            session[adasheId].nextPayment = session[adasheId].nextPayment + dayss;
            session[adasheId].noOfPayed = 0;
            session[adasheId].currentMonth =  session[adasheId].currentMonth + 1;
          }
          
          else{
           session[adasheId].noOfPayed = session[adasheId].noOfPayed + 1;
          }

        }

        //reqquire enddate not reached
      //check user is next in list 
       //pay the users adashe according to list to users account - agent
        function collectFunds(uint adasheId, address payable thisMonthReceiver)  public {

           require(joinedAdashe[adasheId][thisMonthReceiver] == true, 'you have to be in a group');  
          // makesure everyone has  paid
          require(session[adasheId].noOfPayed == adashes[adasheId].noOfPeople, 'Wait till everyone pays');

          //make sure user has not collected before
          require(collected[thisMonthReceiver] != true);

          //withdraw funds before the next payment date
          //require(paydate[thisMonthReceiver] + 28 days < session[adasheId].nextPayment);

          //require address is next in line for payments

          require(session[adasheId].inSession == true, 'this adashe has not started yet');

          require(session[adasheId].noOfCollected < adashes[adasheId].noOfPeople, 'All users has colleted there funds' );
          uint payment = deposits[agent][adasheId];
          //payment has to be same as takehome pay
          //no of payed bak to  zer0
          deposits[agent][adasheId] = 0;
          thisMonthReceiver.transfer(payment);

          collected[thisMonthReceiver] = true;

          session[adasheId].noOfCollected = session[adasheId].noOfCollected + 1;

          if(session[adasheId].noOfCollected == adashes[adasheId].noOfPeople) {
           session[adasheId].inSession == false;
          }



        } 
         
        function adasheSession(uint adasheId, bool inSession, uint nextPayment)  public  {
          //require group full 

          require(adashes[adasheId].adasheMembers.length == adashes[adasheId].noOfPeople, 'The group is ot yet full');
          session[adasheId] = SessionStarted(adasheId, inSession, nextPayment, 0, 0, 0);
          //sess[adasheId].inSession = session;
         
        }


        function checkCollectionDate(uint adasheId, address member)  public returns(uint){
          uint dateOfCollection = paydate[adasheId][member];
          return dateOfCollection;
        }

      

        // uint adasheId;
        //   bool inSession;
        //   uint nextPayment;
        //   uint currentMonth;
        //   uint noOfPayed;
        //   uint noOfCollected;


        //withraw from adashe group before the start date
        
    //who can withdraw 
     //an array that represents who to pay next



    //functions *************

   

   

   
    //create payment table check whether they have paid 
       //each adashe has id create list based nuber of individals
       //month 1   account 1. payed month 1 account 2 payed
       //month 2 account 1/ not payed month 2 account 2 payed
    
    //withdraw funds - user
    //scenario when list is not full and deadlibe is coming full grup with compurer



}












