import os
import xml.etree.ElementTree as ET

def add_permissions(file_path):
    tree = ET.parse(file_path)
    root = tree.getroot()
    ns = {'ns': 'http://soap.sforce.com/2006/04/metadata'}
    ET.register_namespace('', ns['ns'])

    # Add Object Permissions for Signature Request
    obj_req = ET.SubElement(root, 'objectPermissions')
    ET.SubElement(obj_req, 'allowCreate').text = 'true'
    ET.SubElement(obj_req, 'allowDelete').text = 'true'
    ET.SubElement(obj_req, 'allowEdit').text = 'true'
    ET.SubElement(obj_req, 'allowRead').text = 'true'
    ET.SubElement(obj_req, 'modifyAllRecords').text = 'true' if 'Admin' in file_path else 'false'
    ET.SubElement(obj_req, 'object').text = 'DocGen_Signature_Request__c'
    ET.SubElement(obj_req, 'viewAllFields').text = 'false'
    ET.SubElement(obj_req, 'viewAllRecords').text = 'true' if 'Admin' in file_path else 'false'

    # Add Field Permissions for Signature Request
    fields_req = ['Signer_Email__c', 'Signer_Name__c', 'Source_Document_Id__c', 'Secure_Token__c', 'Status__c']
    for field in fields_req:
        fp = ET.SubElement(root, 'fieldPermissions')
        ET.SubElement(fp, 'editable').text = 'true'
        ET.SubElement(fp, 'field').text = f'DocGen_Signature_Request__c.{field}'
        ET.SubElement(fp, 'readable').text = 'true'

    # Add Object Permissions for Signature Audit (Read Only for Users, Full for Admin)
    obj_aud = ET.SubElement(root, 'objectPermissions')
    ET.SubElement(obj_aud, 'allowCreate').text = 'true' if 'Admin' in file_path else 'false'
    ET.SubElement(obj_aud, 'allowDelete').text = 'true' if 'Admin' in file_path else 'false'
    ET.SubElement(obj_aud, 'allowEdit').text = 'true' if 'Admin' in file_path else 'false'
    ET.SubElement(obj_aud, 'allowRead').text = 'true'
    ET.SubElement(obj_aud, 'modifyAllRecords').text = 'true' if 'Admin' in file_path else 'false'
    ET.SubElement(obj_aud, 'object').text = 'DocGen_Signature_Audit__c'
    ET.SubElement(obj_aud, 'viewAllFields').text = 'false'
    ET.SubElement(obj_aud, 'viewAllRecords').text = 'true' if 'Admin' in file_path else 'false'

    # Add Field Permissions for Signature Audit
    fields_aud = ['IP_Address__c', 'User_Agent__c', 'Signed_Date__c', 'Document_Hash_SHA256__c']
    for field in fields_aud:
        fp = ET.SubElement(root, 'fieldPermissions')
        ET.SubElement(fp, 'editable').text = 'true' if 'Admin' in file_path else 'false'
        ET.SubElement(fp, 'field').text = f'DocGen_Signature_Audit__c.{field}'
        ET.SubElement(fp, 'readable').text = 'true'

    # Add Tabs
    for tab in ['DocGen_Signature_Request__c', 'DocGen_Signature_Audit__c']:
        ts = ET.SubElement(root, 'tabSettings')
        ET.SubElement(ts, 'tab').text = tab
        ET.SubElement(ts, 'visibility').text = 'Visible'

    tree.write(file_path, encoding='UTF-8', xml_declaration=True)

update_permissions('force-app/main/default/permissionsets/DocGen_Admin.permissionset-meta.xml')
update_permissions('force-app/main/default/permissionsets/DocGen_User.permissionset-meta.xml')
print('Permissions Updated.')
