/* Modifications faites : 
Création d'une méthode testSetup pour y créer les test data
Création d'une nouvelle méthode pour tester la nouvelle fonctionnalité
Création de deux méthodes pour tester les scénarios négatifs
Création d'une classe Constants pour storer tous les constants dont on aura besoin
Ajouter un parent pour tester la logique
Code écrit par : Hemdene Ben Hammouda*/
@isTest
private class SubscriptionComplianceCheckTest {

// move to constants class

   @testSetup 
    static void setup() {
        Account compte = Account_DataFactory.createAccount('compte_1', '+33 6 00 00 00 00', '37915832200097');
        compte.Segmentation__c = Constants.SSII;
        compte.CompanyIndustry__c = 'Beauty';
        compte.BillingCountry = 'France';
        compte.BillingCity = 'city';
        compte.BillingState = 'Île-de-France';
        compte.BillingPostalCode = '93600';
        compte.BillingStreet = 'street';
        UPDATE compte;
        Acces_beneficiaire__c benef1 = AccesBeneficiaire_DataFactory.createBeneficiaire('benef_1', compte.Id, 'test1@lbc.fr', Constants.CREATED);
        benef1.AccessUserId__c = 'OUAH';
        benef1.AccessStoreId__c = 'OUAH';
        benef1.AccessCategory__c = Constants.MODE;
        benef1.Segmentation__c = Constants.SSII;
        benef1.AccessSalutation__c = Constants.MME;
        benef1.AccessFirstname__c = 'Mimmi';
        benef1.AccessLastname__c = 'Montey';
        benef1.AccessAddressStreet__c = '11 nowhere';
        benef1.AccessAddressCountry__c = 'FR';
        benef1.AccessAddressCity__c = 'city';
        benef1.AccessAddressZipcode__c = '22000';
        UPDATE benef1;
        List<SBQQ_Subscription__c> subscriptionList = new List<SBQQ_Subscription__c>();
        SBQQ_Subscription__c parent = new SBQQ_Subscription__c(
            SBQQ_Quantity__c = 5, Status__c = Constants.ELEMENTS_MANQUANTS, 
            ComplianceProcess__c = Constants.PARENT_BUNDLE);
        INSERT parent;
        SBQQ_Subscription__c immo = new SBQQ_Subscription__c(
            SBQQ_Quantity__c = 5, Status__c = Constants.ELEMENTS_MANQUANTS, ComplianceProcess__c = Constants.IMMO_NEUF, LeadPhone__c = '+33 6 00 00 00 66',
			ProductWorkflow__c = Constants.YEAH, BeneficiaryAccess__c = benef1.Id, FlowType__c = Constants.MANUEL);
        INSERT immo;
        immo.PromoterDescription__c = 'UBIFLOW4';
        immo.ContractEmail__c='testEmail@test.com';
        immo.CompanySiret__c='37915832200097';
        immo.CompanyName__c='Company Name';
        immo.CompanyAddressStreet__c='Address';
        immo.CompanyAddressZipcode__c='ZipCode';
        immo.CompanyAddressCity__c='City';
        immo.CompanyPhone__c='Phone';
        immo.ContactGender__c='Gender';
        immo.ContactFirstName__c='firstName';
        immo.ContactLastName__c='lastName';
        UPDATE immo;
        SBQQ_Subscription__c pub = new SBQQ_Subscription__c(
            SBQQ_Quantity__c = 5, Status__c = Constants.ELEMENTS_MANQUANTS, ComplianceProcess__c = Constants.PUB, LeadPhone__c = '+33 6 00 00 00 66',
			ProductWorkflow__c = Constants.YEAH, BeneficiaryAccess__c = benef1.Id, FlowType__c = Constants.MANUEL);
        INSERT pub;
        pub.EffectiveEndDate__c = Date.Today().addDays(20);
        pub.PromoterDescription__c = 'UBIFLOW5';
        pub.SBQQ_RequiredById__c=parent.Id;
        UPDATE pub;
        subscriptionList.add(new SBQQ_Subscription__c(SBQQ_Quantity__c = 5, Status__c = Constants.ELEMENTS_MANQUANTS, ComplianceProcess__c = Constants.BOUTIQUE, 
                                           ProductWorkflow__c = Constants.YEAH, BeneficiaryAccess__c = benef1.Id, FlowType__c = Constants.MANUEL, BeneficiaryAccount__c = compte.Id));
        subscriptionList.add(new SBQQ_Subscription__c(SBQQ_Quantity__c = 5, Status__c = Constants.ELEMENTS_MANQUANTS, ComplianceProcess__c = Constants.DIFFUSION_LBC, 
                                             ProductWorkflow__c = Constants.YEAH, BeneficiaryAccess__c = benef1.Id, BeneficiaryAccount__c = compte.Id,
                                           BroadcastSoftware__c = Constants.CLOVER, BroadcastPartner__c = Constants.UBIFLOW, FlowType__c = Constants.MANUEL));
        subscriptionList.add(new SBQQ_Subscription__c(SBQQ_Quantity__c = 5, Status__c = Constants.ELEMENTS_MANQUANTS, ComplianceProcess__c = Constants.DIFFUSION_AVAL, FlowType__c = Constants.MANUEL,
                                             ProductWorkflow__c = Constants.YEAH, BeneficiaryAccess__c = benef1.Id, BeneficiaryAccount__c = compte.Id));
        subscriptionList.add(new SBQQ_Subscription__c(SBQQ_Quantity__c = 5, Status__c = Constants.ELEMENTS_MANQUANTS, ComplianceProcess__c = Constants.VISIBILITE_AVAL, FlowType__c = Constants.MANUEL,
                                             ProductWorkflow__c = Constants.YEAH, BeneficiaryAccess__c = benef1.Id, SBQQ_RequiredById__c = parent.Id, BeneficiaryAccount__c = compte.Id));
        subscriptionList.add(new SBQQ_Subscription__c(SBQQ_Quantity__c = 5, Status__c = Constants.ELEMENTS_MANQUANTS, ComplianceProcess__c = Constants.CREDIT, FlowType__c = Constants.MANUEL,
                                             ProductWorkflow__c = Constants.YEAH,BeneficiaryAccess__c = benef1.Id, BeneficiaryAccount__c = compte.Id));
        subscriptionList.add(new SBQQ_Subscription__c(SBQQ_Quantity__c = 5, Status__c = Constants.ELEMENTS_MANQUANTS, ComplianceProcess__c = Constants.PUB_LOCAL, OrderNumber__c = '00215',
                                             PostalCode__c = 7500, KilometerRadius__c = '50', PrintVolume__c = 25));
        INSERT subscriptionList;
    }

    @isTest
    private static void testConformite() {
        
        SubscriptionComplianceCheck batch = new SubscriptionComplianceCheck();
        
		Test.startTest();
		Database.executeBatch(batch);
		Test.stopTest();
        
        List<SBQQ_Subscription__c> subsList = [SELECT Id,ComplianceProcess__c FROM SBQQ_Subscription__c WHERE Souscription_Conforme__c = true];
        System.debug('subsList : '+subsList);
        System.assertEquals(3, [SELECT Id FROM SBQQ_Subscription__c WHERE Souscription_Conforme__c = true].size());
    }

    @isTest 
    private static void testConformitePubNegative() {
        
        SubscriptionComplianceCheck batch = new SubscriptionComplianceCheck();
        SBQQ_Subscription__c subPub = [Select Id,EffectiveEndDate__c,MissingInformations__c,Souscription_Conforme__c from SBQQ_Subscription__c where ComplianceProcess__c = :Constants.PUB limit 1];
        subPub.EffectiveEndDate__c = Date.Today().addDays(- 5);
        update subPub;

		Test.startTest();
		Database.executeBatch(batch);
		Test.stopTest();
        
        SBQQ_Subscription__c subPubFinal = [Select Id,MissingInformations__c from SBQQ_Subscription__c where ComplianceProcess__c = :Constants.PUB limit 1];
        System.assertEquals(Constants.MISSING_INFO,subPubFinal.MissingInformations__c);
        System.assertEquals(1, [SELECT Id FROM SBQQ_Subscription__c WHERE Souscription_Conforme__c = true].size());
    }

    @isTest 
    private static void testConformiteImmoNegative() {
        
        SubscriptionComplianceCheck batch = new SubscriptionComplianceCheck();
        SBQQ_Subscription__c subImmo = [Select Id,LeadPhone__c,MissingInformations__c,Souscription_Conforme__c from SBQQ_Subscription__c where ComplianceProcess__c = :Constants.IMMO_NEUF limit 1];
        subImmo.LeadPhone__c = null ;
        update subImmo;

		Test.startTest();
		Database.executeBatch(batch);
		Test.stopTest();
        
        SBQQ_Subscription__c subImmoFinal = [Select Id,MissingInformations__c from SBQQ_Subscription__c where ComplianceProcess__c = :Constants.IMMO_NEUF limit 1];
        System.assertEquals(Constants.MISSING_INFO,subImmoFinal.MissingInformations__c);
        System.assertEquals(2, [SELECT Id FROM SBQQ_Subscription__c WHERE Souscription_Conforme__c = true].size());

    }
}