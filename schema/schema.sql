CREATE SEQUENCE uw_Tables_user_id_seq;
 
 CREATE TABLE uw_Tables_users(uw_id int8 NOT NULL, uw_fullname text NOT NULL, 
                               uw_role text NOT NULL, uw_email text NOT NULL
  );
  
  CREATE SEQUENCE uw_Tables_expense_id_seq;
   
   CREATE TABLE uw_Tables_expenses(uw_id int8 NOT NULL, uw_title text NOT NULL, 
                                    uw_amount float8 NOT NULL, 
                                    uw_category text NOT NULL, 
                                    uw_description text NOT NULL, 
                                    uw_ownerid int8 NOT NULL, 
                                    uw_state text NOT NULL, 
                                    uw_createdat timestamp NOT NULL, 
                                    uw_updatedat timestamp NOT NULL
    );
    
    CREATE SEQUENCE uw_Tables_audit_id_seq;
     
     CREATE TABLE uw_Tables_audit_log(uw_id int8 NOT NULL, 
                                       uw_expenseid int8 NOT NULL, 
                                       uw_actorid int8 NOT NULL, 
                                       uw_oldstate text NOT NULL, 
                                       uw_newstate text NOT NULL, 
                                       uw_comment text NOT NULL, 
                                       uw_stamp timestamp NOT NULL
      );
      
      