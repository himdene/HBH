/* Modifications faites : 
start() : Changer les fields de lal SOQL query pour que la query soit plus optimale
execute() : Enlever les Opérations DML des boucles
setParentConforme() : Changing parameters to bulkify the code so it accepts a list 
setConformiteImmoNeuf() : Changing parameters to bulkify the code and also changing the retrun type to void
setConformitePub() : implémentation d'une méthode selon le nouveau besoin*
finish(): ajouter les logs pour enregistrer les success
Création d'une classe Constants pour storer tous les constants dont on aura besoin
Code écrit par : Hemdene Ben Hammouda*/
global class SubscriptionComplianceCheck implements Database.Batchable<sObject> {
    // move to Constants class
    
    global List<SBQQ_Subscription__c> start(Database.BatchableContext bc) { 
         // enlever les champs non nécessaires pour que la SOQL query soit plus rapide
         return [SELECT Id, CompanyAddressCity__c, CompanyPhone__c, ContactGender__c, ContactLastName__c, 
                 ContactFirstName__c, CompanyName__c, PromoterDescription__c, SBQQ_RequiredById__c,
                 FlowType__c, Souscription_Conforme__c, ComplianceProcess__c, Status__c, EffectiveEndDate__c,
                 ProductWorkflow__c, CompanyAddressStreet__c, CompanyAddressZipcode__c, LeadPhone__c,
                 ContractEmail__c, CompanySiret__c FROM SBQQ_Subscription__c WHERE Status__c = :Constants.ELEMENTS_MANQUANTS
                 AND Souscription_Conforme__c = false];
    }
    
    global void execute(Database.BatchableContext bc, List<SBQQ_Subscription__c> scope) {
        try {
            Set<String> parentIds = new Set<String>();
            List<SBQQ_Subscription__c> subsImmoList = new List<SBQQ_Subscription__c>();
            List<SBQQ_Subscription__c> subsPubList = new List<SBQQ_Subscription__c>();
            List<SBQQ_Subscription__c> subsConformeList = new List<SBQQ_Subscription__c>();
            for(SBQQ_Subscription__c sub : scope) {    
                //enlever les DML opérations dans les boucles
               if (sub.ComplianceProcess__c == Constants.IMMO_NEUF) {
                    subsImmoList.add(sub);
                }
                if(sub.ComplianceProcess__c == Constants.PUB){
                    subsPubList.add(sub);
                }
            }
            if(!subsImmoList.isEmpty()){
                setConformiteImmoNeuf(subsImmoList);
                subsConformeList.addAll(subsImmoList);
            }
            if(!subsPubList.isEmpty()){
                setConformitePub(subsPubList);
                subsConformeList.addAll(subsPubList);
            }
            if(!subsConformeList.isEmpty()){
                for(SBQQ_Subscription__c sub :subsConformeList ){
                    if(sub.SBQQ_RequiredById__c != null && sub.Souscription_Conforme__c ){
                        parentIds.add(sub.SBQQ_RequiredById__c);
                    }  
                }
            }
            if(!parentIds.isEmpty()){
                setParentConforme(parentIds);
            } 
        } catch(Exception e) {
            Logs.error('SubscriptionComplianceCheck','Batch Compliance Check', e);
        }
    }
    // ajouter les méthodes info et trace pour capturer le success
    global void finish(Database.BatchableContext bc) {
        Logs.info('SubscriptionComplianceCheck','execute','Successfully Update Subscriptions');
        Logs.trace('SubscriptionComplianceCheck','execute','Successfully Update Subscriptions');
    }
    
    private void setConformitePub(List<SBQQ_Subscription__c> subsList){
        for(SBQQ_Subscription__c sub : subsList){
            if(sub.EffectiveEndDate__c > Date.Today()){
            sub.Souscription_Conforme__c = true;
            }
            else{
                sub.MissingInformations__c= Constants.MISSING_INFO;   
            }
        }
        Update subsList;
    }
    //changer le type en void pour éviter de faire des opération DML dans les boucles
    private void setConformiteImmoNeuf(List<SBQQ_Subscription__c> subsList) {
        for(SBQQ_Subscription__c sub : subsList){
            if(sub.PromoterDescription__c != null && sub.FlowType__c != null && sub.ProductWorkflow__c != null
            && sub.ContractEmail__c != null && sub.CompanySiret__c != null && sub.CompanyName__c != null
            && sub.CompanyAddressStreet__c != null && sub.CompanyAddressZipcode__c != null && sub.CompanyAddressCity__c != null
            && sub.CompanyPhone__c != null && sub.ContactGender__c != null && sub.ContactFirstName__c != null 
            && sub.ContactLastName__c != null && sub.LeadPhone__c != null) {
                sub.Souscription_Conforme__c = true;
            }
            else{
                sub.MissingInformations__c= Constants.MISSING_INFO;   
            }
        }
        Update subsList;
    }
    //changer le paramètre pour recevoir une liste pour faire un bulk update
    private void setParentConforme(Set<String> parentIds) {
        List<SBQQ_Subscription__c> parentSub = [SELECT Id, Souscription_Conforme__c FROM SBQQ_Subscription__c WHERE Status__c = :Constants.ELEMENTS_MANQUANTS 
                                           AND Souscription_Conforme__c = false AND Id IN :parentIds];
        if (parentSub.size() > 0) {
            for(SBQQ_Subscription__c sub :parentSub ){
                sub.Souscription_Conforme__c = true;
            }
            
            UPDATE parentSub;
        }
    }
}