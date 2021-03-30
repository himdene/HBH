/* Modifications faites : 
Suivant les bonnes pratiques de Salesforce j'ai crée une class helper et mis toute la logique dedans 
Aussi pour pouvoir utiliser un seul trigger par object comme Salesforce le suggère on vérifie si on est dans le bon context avant d'appeler la helper class
Code écrit par : Hemdene Ben Hammouda*/
trigger ContractEndDateAdapterTrigger on SBQQ_Subscription__c (after insert, after update) {

   if(Trigger.isAfter){
       if(Trigger.isInsert || Trigger.isUpdate){
           ContractEndDateAdapterHelper.updateEndDate(Trigger.new);
       }
   }
    
}