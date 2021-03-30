/* Class helper 
toute la logique du trigger palcée ici pour suivre les bonnes pratiques de Salesforce
Code écrit par : Hemdene Ben Hammouda*/
public with sharing Class ContractEndDateAdapterHelper{

    public static void updateEndDate(List<SBQQ_Subscription__c> subscriptionList){
        Set<Id> contractIds = new Set<Id>();
        for (SBQQ_Subscription__c sub :subscriptionList) {
            contractIds.add(sub.SBQQ_Contract__c);
        }
        try {
            List<Contract> contractsList = new List<Contract>();
            for (Contract con : [SELECT Id, EndDate, (SELECT Id, SBQQ_EndDate__c, SBQQ_TerminatedDate__c, SBQQ_Contract__c 
                                                FROM SBQQ_Subscriptions__r) FROM Contract WHERE Id IN :contractIds]) {
                                                    system.debug('contrat on :: '+con)   ; 

                for (SBQQ_Subscription__c sub : con.SBQQ_Subscriptions__r) {

                    if (sub.SBQQ_TerminatedDate__c != null && con.EndDate < sub.SBQQ_TerminatedDate__c) {
                        con.EndDate = sub.SBQQ_TerminatedDate__c;
                    }
                    if (sub.SBQQ_EndDate__c != null && con.EndDate < sub.SBQQ_EndDate__c) {
                        con.EndDate = sub.SBQQ_EndDate__c;
                    }
                }
                                    
                contractsList.add(con);
            }
            if(contractsList != null){
                UPDATE contractsList;
                Logs.info('ContractEndDateAdapterHelper','updateEndDate','Successfully Update Contacts');
                Logs.trace('ContractEndDateAdapterHelper','updateEndDate','Successfully Update Contacts');
            }    
        } catch(Exception e) {
                Logs.error('ContractEndDateAdapterHelper','updateEndDate', e);
        }
    }
}