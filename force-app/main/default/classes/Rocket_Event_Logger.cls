public with sharing class Rocket_Event_Logger {
    // class vars used by Visualforce Rocket Logger Page
    public Integer rows {get;set;}
    public String error {get;set;}
    public String qUserId {get;set;}
    public String qLogLevelContains {get;set;}
    public String selectedLogLevel {get;set;}
    public String qDebugMessageContains {get;set;}
    public String qClassContains {get;set;}
    public String qMethodContains {get;set;}
    public String qExceptionTypeContains {get;set;}
    public String qExceptionContains {get;set;}
    public String qRequestMapContains {get;set;}
    public String qResponseMapContains {get;set;}
    public String qTimestampContains {get;set;}
    public String qTimestampStart {get;set;}
    public String qTimestampEnd {get;set;}
    public String selectedTimestamp {get;set;}
    public Boolean bConfirmState {get;set;}
    public Boolean bShowDeleteButton {get; set;}


    // for visual force page dropdown
    public List<SelectOption> getLogLevels() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--ANY--'));
        options.add(new SelectOption('INFO','INFO'));
        options.add(new SelectOption('WARN','WARN'));
        options.add(new SelectOption('DEBUG','DEBUG'));
        options.add(new SelectOption('ERROR','ERROR'));
        return options;
    }

    // for visual force page dropdown
    public List<SelectOption> getTimestampOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--ANY--'));
        options.add(new SelectOption('TODAY','TODAY'));
        options.add(new SelectOption('YESTERDAY','YESTERDAY'));
        options.add(new SelectOption('THIS_WEEK','THIS_WEEK'));
        options.add(new SelectOption('THIS_MONTH','THIS_MONTH'));
        options.add(new SelectOption('LAST_MONTH','LAST_MONTH'));
        options.add(new SelectOption('LAST_90_DAYS','LAST_90_DAYS'));
        options.add(new SelectOption('THIS_YEAR','THIS_YEAR'));
        options.add(new SelectOption('LAST_YEAR','LAST_YEAR'));
        options.add(new SelectOption('--CHOOSE SPECIFIC--','--CHOOSE SPECIFIC--'));
        return options;
    }

    // for visual force page records
    public List<Rocket_Logger__c> logEntries {get;set;}

    // for visual force page selection action
    public void setLogLevelValue() {
        qLogLevelContains = selectedLogLevel;
    }

    // for visual force page selection action
    public void setTimestampValue() {
        qTimestampContains = selectedTimestamp;
    }

    // datetime for string
    private Datetime convertStringToDatetime (String dt) {
        List<String> dateTimeParts = dt.split(' ');
        List<String> dateParts = dateTimeParts[0].split('/');
        List<String> timeParts = dateTimeParts[1].split(':');
        Time myTime = Time.newInstance(Integer.valueOf(timeParts[0]), Integer.valueOf(timeParts[1]), Integer.valueOf(timeParts[2]), 0);
        if (dateTimeParts[2] == 'PM') {
           myTime = myTime.addHours(12);
        }
        Date myDate = Date.newInstance(Integer.valueOf(dateParts[2]), Integer.valueOf(dateParts[0]), Integer.valueOf(dateParts[1]));
        Datetime myDatetime = Datetime.newInstance(myDate, myTime);
        return myDatetime;
    }

    // for visual force page search
    public void searchWithFilters(){
        rows = 0;
        error = '';

        try {
            // set up base query
            string searchquery='SELECT User_Id__c, LogLevel__c, DebugMessage__c, Class__c, Method__c, ExceptionType__c, ExceptionMessage__c, RequestMap__c, ResponseMap__c, Timestamp__c FROM Rocket_Logger__c';
            List<Rocket_Logger__c> logEntriesBeforeLongFieldFiltering = new List<Rocket_Logger__c>();
            List<Rocket_Logger__c> filteredLogEntries = new List<Rocket_Logger__c>();

            List<String> clauses = new List<String>();
            if (qTimestampContains != null) {
                if (qTimestampContains != '') {
                    if (selectedTimestamp != '--CHOOSE SPECIFIC--') {
                        String filter = 'Timestamp__c >= ' + qTimestampContains;
                        clauses.add(filter);
                    }
                    else {
                        if (qTimestampStart != null && qTimestampStart != '' && qTimestampEnd != null && qTimestampEnd != '') {
                            Datetime dtStart = convertStringToDatetime(qTimestampStart);
                            Datetime dtEnd = convertStringToDatetime(qTimestampEnd);
                            String filter = 'Timestamp__c >= ' + dtStart.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' AND Timestamp__c <= ' + dtEnd.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
                            clauses.add(filter);
                        } else {
                            error = 'For Specific Timestamps, you must include both start and end time.';
                            return;
                        }
                    }
                }
            }
            if (qUserId != null) {
                if (qUserId != '') {
                    String filter = 'User_Id__c = \'' + qUserId + '\'';
                    clauses.add(filter);
                }
            }

            if (qLogLevelContains != null) {
                if (qLogLevelContains != '') {
                    String filter = 'LogLevel__c = \'' + qLogLevelContains + '\'';
                    clauses.add(filter);
                }
            }
            if (qDebugMessageContains != null) {
                if (qDebugMessageContains != '') {
                    String filter = 'DebugMessage__c LIKE \'%' + qDebugMessageContains + '%\'';
                    clauses.add(filter);
                }
            }
            if (qClassContains != null) {
                if (qClassContains != '') {
                    String filter = 'Class__c LIKE \'%' + qClassContains + '%\'';
                    clauses.add(filter);
                }
            }
            if (qMethodContains != null) {
                if (qMethodContains != '') {
                    String filter = 'Method__c LIKE \'%' + qMethodContains + '%\'';
                    clauses.add(filter);
                }
            }
            if (qExceptionTypeContains != null) {
                if (qExceptionTypeContains != '') {
                    String filter = 'ExceptionType__c LIKE \'%' + qExceptionTypeContains + '%\'';
                    clauses.add(filter);
                }
            }
            for(Integer i=0; i <= clauses.size()-1 ; i++){
                if (i == 0) {
                    searchquery+= ' WHERE ';
                }
                searchquery += clauses[i];
                if (i < clauses.size()-1) {
                    searchquery+= ' AND ';
                }
            }

            searchquery += ' ORDER BY Timestamp__c DESC';

            logEntriesBeforeLongFieldFiltering = Database.query(searchquery);

            Boolean filterException = false;
            if (qExceptionContains != null) {
                if (qExceptionContains != '') {
                    filterException = true;
                }
            }

            Boolean filterRequest = false;
            if (qRequestMapContains != null) {
                if (qRequestMapContains != '') {
                    filterRequest = true;
                }
            }

            Boolean filterResponse = false;
            if (qResponseMapContains != null) {
                if (qResponseMapContains != '') {
                    filterResponse = true;
                }
            }

            Boolean requiresFiltering = filterRequest || filterResponse || filterException;

            if (requiresFiltering) {
                for(Rocket_Logger__c logEntry : logEntriesBeforeLongFieldFiltering) {
                    Boolean canAddEntry = true;
                    if (filterRequest) {
                        if (logEntry.RequestMap__c.contains(qRequestMapContains)) {
                            canAddEntry = true;
                        } else {
                            canAddEntry = false;
                        }
                    }
                    if (filterResponse && canAddEntry) {
                        if (logEntry.ResponseMap__c.contains(qResponseMapContains)) {
                            canAddEntry = true;
                        } else {
                            canAddEntry = false;
                        }
                    }
                    if (filterException && canAddEntry) {
                        if (logEntry.ExceptionMessage__c.contains(qExceptionContains)) {
                            canAddEntry = true;
                        } else {
                            canAddEntry = false;
                        }
                    }
                    if (canAddEntry) {
                        filteredLogEntries.add(logEntry);
                    }
                }
                logEntries = filteredLogEntries;
            } else {
                logEntries = logEntriesBeforeLongFieldFiltering;
            }

            rows = logEntries.size();
            bConfirmState = false;
            if (rows > 0) {
                bShowDeleteButton = true;
            } else {
                bShowDeleteButton = false;
            }

        }  catch (Exception e) {
            error = e.getMessage();
        }
    }

    // for visual force page search using query parameter
    public void searchByQueryUserId(){
        String qsUserId = ApexPages.currentPage().getParameters().get('UserId');
        if (qsUserId != null) {
            qUserId = qsUserId; // set the field
            rows = 0;
            error = '';
            try {
                logEntries = [SELECT
                                    User_Id__c,
                                    LogLevel__c,
                                    DebugMessage__c,
                                    Class__c,
                                    Method__c,
                                    ExceptionType__c,
                                    ExceptionMessage__c,
                                    RequestMap__c,
                                    ResponseMap__c,
                                    Timestamp__c
                            FROM Rocket_Logger__c
                            WHERE User_Id__c = :qsUserId
                            ORDER BY Timestamp__c DESC];

                rows = logEntries.size();
                bConfirmState = false;
                if (rows > 0) {
                    bShowDeleteButton = true;
                } else {
                    bShowDeleteButton = false;
                }
            }  catch (Exception e) {
                error = e.getMessage();
            }

        }
    }

    // for confirmation state
    public void confirmDelete() {
        bConfirmState = true;
    }

    // for cancel delete
    public void cancelDelete() {
        bConfirmState = false;
    }

    // for deleting log entries
    public void deleteLogEntries() {
        try {
            delete logEntries;
            //perform search again
            searchWithFilters();
        } catch (Exception e) {
            error = e.getMessage();
        }
        bConfirmState = false;
    }

    /* NON VISUAL FORCE PAGE METHODS */

    /**
     * @description publish a Rocket Logger Platform Event
     * @param ex Exception to be logged
     * @param debugMessage String to provide debug message for record
     * @param logLevel String to provide logging level (INFO, WARN, DEBUG, ERROR)
     * @param className String of classname (used by Front End otherwise obtained from stacktrace)
     * @param logLevel String of method (used by Front End otherwise obtained from stacktrace)
     * @param requestMap Map<String,Object> of request to be serialized and inserted to log record
     * @param responseMap Map<String,Object> of response to be serialized and inserted to log record
     */
    private static void logEvent(Exception ex, String debugMessage, String logLevel, String className, String methodName, Map<String,Object> requestMap, Map<String,Object> responseMap){
        String exceptionMsg = '';
        String exceptionType = '';
        String stackTrace = '';
        String stackFirstLine = '';
        String cls = '';
        String method = '';

        Rocket_Logger_Event__e logEvent = new Rocket_Logger_Event__e();

        logEvent.Level__c = logLevel;
        logEvent.Message__c = debugMessage;
        logEvent.User_Id__c = UserInfo.getUserId();

        if(ex == null){
            // if no exception passed in such as for INFO/WARN/DEBUG log
            // create a new exception to automatically get class/method name
            ex = new DmlException();
            stackTrace = ex.getStackTraceString();
            stackFirstLine = stackTrace.substringAfter('\n').substringAfter('\n');
        } else{
            stackTrace = ex.getStackTraceString();
            stackFirstLine = stackTrace.substringBefore('\n');
            exceptionType = ex.getTypeName();
            exceptionMsg = 'Message: ' + ex.getMessage() +
                                '\nCause: ' + ex.getCause() +
                                '\nLine Number: ' + ex.getLineNumber() +
                                '\nStack trace: ' + stackTrace;
        }

        // class and method can be passed from front end.
        //  if not, get them from the stack trace
        if (className == null) {
            cls = getClassName(stackFirstLine);
        }
        if (method == null) {
            method = getMethod(stackFirstLine);
        }


        logEvent.Exception__c = exceptionMsg;
        logEvent.Exception_Type__c = exceptionType;
        logEvent.Method__c = method;
        logEvent.Class__c = cls;
        logEvent.Timestamp__c = Datetime.now();
        logEvent.Request_Map__c = JSON.serializePretty(requestMap);
        logEvent.Response_Map__c = JSON.serializePretty(responseMap);

        // TODO:  check if exception message > 131072.  If so, may need to split into multiple events

        // Call method to publish event(s) - if multiple, this should be a List
        Database.SaveResult result = EventBus.publish(logEvent);

        // if multiple, this will need to be a for each
        if (result.isSuccess()) {
            // Successfully published event
        } else {
            for(Database.Error err : result.getErrors()) {
                System.debug('Error Publishing Rocket Logger event! Returned: ' +
                            err.getStatusCode() +
                            ' - ' +
                            err.getMessage());
            }
        }

    }

    /**
     * @description create log event with log level ERROR and no other payload
     * @param ex Exception to be logged
     * @param debugMessage String to provide debug message for record
     */
    public static void error(Exception ex, String debugMessage){
        logEvent(ex,debugMessage, Rocket_GlobalConstants.ERROR, null, null, null, null);
    }

    /**
     * @description create log event with log level ERROR and request or response payloads
     * @param ex Exception to be logged
     * @param debugMessage String to provide debug message for record
     * @param requestMap Map<String,Object> of request data to be serialized and included on record
     * @param responseMap Map<String,Object> of response data to be serialized and included on record
     */
    public static void error(Exception ex, String debugMessage, Map<String,Object> requestMap, Map<String,Object> responseMap){
        logEvent(ex,debugMessage, Rocket_GlobalConstants.ERROR, null, null, requestMap, responseMap);
    }

    /**
     * @description create log event with log level DEBUG and no other payload or exception given
     * @param debugMessage String to provide debug message for record
     */
    public static void debug(String debugMessage){
        logEvent(null,debugMessage, Rocket_GlobalConstants.DEBUG, null, null, null, null);
    }

    /**
     * @description create log event for exception with log level DEBUG and no other payload
     * @param ex Exception to be logged
     * @param debugMessage String to provide debug message for record
     */
    public static void debug(Exception ex, String debugMessage){
        logEvent(ex,debugMessage, Rocket_GlobalConstants.DEBUG, null, null, null, null);
    }

    /**
     * @description create log event with log level DEBUG and request or response payloads without exception given
     * @param debugMessage String to provide debug message for record
     * @param requestMap Map<String,Object> of request data to be serialized and included on record
     * @param responseMap Map<String,Object> of response data to be serialized and included on record
     */
    public static void debug(String debugMessage, Map<String,Object> requestMap, Map<String,Object> responseMap){
        logEvent(null,debugMessage, Rocket_GlobalConstants.DEBUG, null, null, requestMap, responseMap);
    }

    /**
     * @description create log event for exception with log level DEBUG and request or response payloads
     * @param ex Exception to be logged
     * @param debugMessage String to provide debug message for record
     * @param requestMap Map<String,Object> of request data to be serialized and included on record
     * @param responseMap Map<String,Object> of response data to be serialized and included on record
     */
    public static void debug(Exception ex, String debugMessage, Map<String,Object> requestMap, Map<String,Object> responseMap){
        logEvent(ex,debugMessage, Rocket_GlobalConstants.DEBUG, null, null, requestMap, responseMap);
    }

    /**
     * @description create log event with log level WARN and no other payload or exception given
     * @param debugMessage String to provide debug message for record
     */
    public static void warn(String debugMessage){
        logEvent(null,debugMessage, Rocket_GlobalConstants.WARN, null, null, null, null);
    }

    /**
     * @description create log event for exception with log level WARN and no other payload
     * @param ex Exception to be logged
     * @param debugMessage String to provide debug message for record
     */
    public static void warn(Exception ex, String debugMessage){
        logEvent(ex,debugMessage, Rocket_GlobalConstants.WARN, null, null, null, null);
    }

    /**
     * @description create log event with log level WARN and request or response payloads without exception given
     * @param debugMessage String to provide debug message for record
     * @param requestMap Map<String,Object> of request data to be serialized and included on record
     * @param responseMap Map<String,Object> of response data to be serialized and included on record
     */
    public static void warn(String debugMessage, Map<String,Object> requestMap, Map<String,Object> responseMap){
        logEvent(null,debugMessage, Rocket_GlobalConstants.WARN, null, null, requestMap, responseMap);
    }

    /**
     * @description create log event for exception with log level WARN and request or response payloads
     * @param ex Exception to be logged
     * @param debugMessage String to provide debug message for record
     * @param requestMap Map<String,Object> of request data to be serialized and included on record
     * @param responseMap Map<String,Object> of response data to be serialized and included on record
     */
    public static void warn(Exception ex, String debugMessage, Map<String,Object> requestMap, Map<String,Object> responseMap){
        logEvent(ex,debugMessage, Rocket_GlobalConstants.WARN, null, null, requestMap, responseMap);
    }

    /**
     * @description create log event with log level INFO and no other payload or exception given
     * @param debugMessage String to provide debug message for record
     */
    public static void info(String debugMessage){
        logEvent(null,debugMessage, Rocket_GlobalConstants.INFO, null, null, null, null);
    }

    /**
     * @description create log event with log level INFO and request or response payloads without exception given
     * @param debugMessage String to provide debug message for record
     * @param requestMap Map<String,Object> of request data to be serialized and included on record
     * @param responseMap Map<String,Object> of response data to be serialized and included on record
     */
    public static void info(String debugMessage, Map<String,Object> requestMap, Map<String,Object> responseMap){
        logEvent(null,debugMessage, Rocket_GlobalConstants.INFO, null, null, requestMap, responseMap);
    }


    /**
     * @description returns the class name from a given stack trace line
     * @param line String containing the stack trace line
     * @return String containing the class name extracted from a stack trace line
     */
    private static String getClassName(String line)
    {
        if (line.startsWith('Class.'))
            line = line.substringAfter('Class.');
        return line.substringBefore(':').substringBeforeLast('.');
    }

    /**
     * @description returns the method name from a given stack trace line
     * @param line String containing the stack trace line
     * @return String containing the method name extracted from a stack trace line
     */
    private static String getMethod(String line)
    {
        return line.substringBefore(':').substringAfterLast('.');
    }

    // allow logging from LWC
    @AuraEnabled
    public static void logError(String ex, String debugMessage, String logLevel, String className, String method, String request, String response) {
        Map<String,Object> requestMap = new Map<String,Object>();
        Map<String,Object> responseMap = new Map<String,Object>();
        try {
            if (request != null) {
                requestMap = (Map<String,Object>)JSON.deserialize(request,Map<String,Object>.class);
            }
            if (response != null) {
                responseMap = (Map<String,Object>)JSON.deserialize(request,Map<String,Object>.class);
            }
        } catch (Exception e) {
            System.debug('could not parse request/response');
        }

        Exception e = new HandledException();
        e.setMessage(ex);

        logEvent(e,debugMessage, logLevel, className, method, requestMap, responseMap);
    }
}