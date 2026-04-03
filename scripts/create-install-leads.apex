// Create Leads for all package installs with researched countries
// Skip demo/scratch/test orgs, deduplicate sandboxes under same company

// Collect existing lead companies to avoid duplicates
Set<String> existingCompanies = new Set<String>();
for (Lead l : [SELECT Company FROM Lead WHERE LeadSource IN ('DocGen Install', 'Package Install')]) {
    existingCompanies.add(l.Company.toLowerCase());
}

List<Lead> newLeads = new List<Lead>();

// Map of org name -> country (researched)
// German orgs
Map<String, String> orgCountry = new Map<String, String>{
    'Tafel Deutschland e.V.' => 'Germany',
    'Gesundheit Berlin-Brandenburg e.V., Gemeindedolmetschdienst Berlin | GDD' => 'Germany',
    'Arlanis Reply GmbH' => 'Germany',
    'intouch hcc GmbH - Hartmann' => 'Germany',
    // UAE
    'Emaar Hospitality' => 'United Arab Emirates',
    'Dubai Holding' => 'United Arab Emirates',
    // India
    'InfoBeans CloudTech Limited' => 'India',
    'Novabiz Consulting Pvt. Ltd.' => 'India',
    'Infosys' => 'India',
    'Tirnav Solution' => 'India',
    'Cloudzlab' => 'India',
    // US
    'Riot Games Global Sales' => 'United States',
    'State Department of Education' => 'United States',
    'Serotte Law Firm, LLC' => 'United States',
    'NAMI-NYC (National Alliance on Mental Illness of New York City)' => 'United States',
    'Trinity Law School' => 'United States',
    'Senior Services MOW' => 'United States',
    'Abine (dba DeleteMe)' => 'United States',
    'Chabad Girls High School' => 'United States',
    'TMS Consulting' => 'United States',
    'Bricks Alliance, Inc.' => 'United States',
    'RxSight, Inc.' => 'United States',
    'Butler University' => 'United States',
    'NF2 BioSolutions' => 'United States',
    'Load Bearing Wall Pros' => 'United States',
    'Gates Foundation' => 'United States',
    'Heralds of Hope, Inc.' => 'United States',
    'Golaith Inc' => 'United States',
    'Nike' => 'United States',
    'Gordon College' => 'United States',
    'Pinnacle Group' => 'United States',
    'RPM Performance Coatings Group (PCG)' => 'United States',
    'JCI' => 'United States',
    'Deloitte' => 'United States',
    'Go HQ' => 'United States',
    'Stellar' => 'United States',
    'MOF' => 'United States',
    'AFL' => 'United States',
    'Silk' => 'United States',
    // Austria
    'Avcon Jet AG' => 'Austria',
    // Australia
    'Round Rock Systems Pty Ltd' => 'Australia',
    // New Zealand
    'Spark Wholesale' => 'New Zealand',
    // France
    'Sodexo SA' => 'France',
    // UK
    'Metropolitan Thames Valley' => 'United Kingdom',
    // Nigeria
    'Amaigbo community' => 'Nigeria',
    // Brazil
    'Welisa' => 'Brazil',
    // Colombia
    'Avenoir' => 'Colombia',
    // Mexico
    'Tangelo Labs' => 'Mexico',
    // Canada
    'Docebo' => 'Canada',
    'One360' => 'Canada',
    // Spain
    'Astreca' => 'Spain',
    // India
    'Astralintu Space Technologies' => 'India',
    // Saudi Arabia
    'Bluran' => 'Saudi Arabia',
    // Switzerland
    'KPMG Law' => 'Switzerland'
};

// Dedupe: track companies we've already added (normalize to lowercase)
Set<String> added = new Set<String>();

for (String orgName : orgCountry.keySet()) {
    String key = orgName.toLowerCase();
    if (existingCompanies.contains(key) || added.contains(key)) {
        continue;
    }
    added.add(key);

    newLeads.add(new Lead(
        LastName = orgName,
        Company = orgName,
        Country = orgCountry.get(orgName),
        LeadSource = 'Package Install',
        Status = 'New',
        Description = 'Auto-created from Package Install Tracker bulk sync.'
    ));
}

if (!newLeads.isEmpty()) {
    insert newLeads;
    System.debug('Created ' + newLeads.size() + ' leads');
} else {
    System.debug('No new leads to create');
}

// Fix existing NZ lead
List<Lead> nzLeads = [SELECT Id, Country FROM Lead WHERE Country = 'NZ' LIMIT 1];
if (!nzLeads.isEmpty()) {
    nzLeads[0].Country = 'New Zealand';
    update nzLeads;
    System.debug('Fixed NZ -> New Zealand');
}

// Show summary
Integer totalLeads = [SELECT COUNT() FROM Lead WHERE LeadSource IN ('DocGen Install', 'Package Install') AND Country != null];
System.debug('Total leads with country: ' + totalLeads);

List<AggregateResult> byCountry = [
    SELECT Country, COUNT(Id) cnt FROM Lead
    WHERE LeadSource IN ('DocGen Install', 'Package Install') AND Country != null
    GROUP BY Country ORDER BY Country
];
for (AggregateResult ar : byCountry) {
    System.debug(ar.get('Country') + ': ' + ar.get('cnt'));
}
