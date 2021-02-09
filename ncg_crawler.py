# this script queries the NCG6 website for every cancer and tissue type available as of feb2021, and adds the resultant list of genes to an output file in json format


import requests
import os
import sys
import json
from bs4 import BeautifulSoup

# parse mode from args
if (len(argv) < 2):
	print("please enter a mode: (cancer or type)")

url = 'http://ncg.kcl.ac.uk/query.php'
cancerTypes = ['acute_lymphoblastic_leukemia', 'acute_lymphocytic_leukemia', 'acute_monocytic_leukemia', 'acute_myeloid_leukemia', 'acute_promyelocytic_leukemia', 'adrenocortical_adenoma', 'adrenocortical_carcinoma', 'ameloblastoma', 'ampullary_adenocarcinoma', 'anaplastic_thyroid_carcinoma', 'angioimmunoblastic_T-cell_lymphoma', 'angiosarcoma', 'astrocytoma', 'biliary_tract_cancer', 'bladder_cancer', 'bone_giant_cell_tumour', 'breast_cancer', 'breast_fibroadenoma', 'cervical_cancer_(all_histologies)', 'cholangiocarcinoma', 'chondroblastoma', 'chondromyxoid_fibroma', 'chondrosarcoma', 'chromophobe_renal_cell_carcinoma', 'chronic_lymphocytic_leukemia', 'chronic_myeloid_leukemia', 'chronic_myelomonocytic_leukemia', 'clear_cell_endometrial_cancer', 'clear_cell_renal_cancer', 'colorectal_adenocarcinoma', 'craniopharyngioma', 'cutaneous_DLBCL', 'cutaneous_T_cell_lymphoma', 'desmoplastic_melanoma', 'diffuse_gastric_adenocarcinoma', 'diffuse_intrinsic_pontine_glioma', 'diffuse_large_B-cell_lymphoma', 'duodenal_adenocarcinoma', 'endometrial_cancer', 'esophageal_(squamous_and_adenocarcinoma)', 'esophageal_adenocarcinoma', 'esophageal_squamous_carcinoma', 'ewing_sarcoma', 'follicular_lymphoma', 'gallbladder_carcinoma', 'glioblastoma', 'glioma', 'hepatocellular_carcinoma', 'intracranial_germ_cell', 'juvenile_myelomonocytic_leukemia', 'leiomyoma', 'low_grade_glioma', 'lung_adenocarcinoma', 'lung_cancer_(all_histologies)', 'lung_squamous_cell_carcinoma', 'male_breast_cancer', 'malignant_peripheral_nerve_sheath_tumour', 'malignant_pleural_mesothelioma', 'mediastinal_B-cell_lymphoma', 'medulloblastoma', 'melanoma', 'meningioma', 'mucinous_gastric_cancer', 'mucosal_melanoma', 'multiple_myeloma', 'myelodysplasia', 'myeloproliferative_neoplasm', 'nasopharyngeal_carcinoma', 'natural_killer/T_cell_lymphoma', 'neuroblastoma', 'neuroendocrine_tumour', 'non-clear_cell_renal_cancer', 'non-Hodgkin_lymphoma', 'non-small_cell_lung_cancer', 'oligodendroglioma', 'oral_squamous_cell_carcinoma', 'osteosarcoma', 'ovarian_cancer', 'ovarian_clear-cell_carcinoma', 'ovarian_serous_carcinoma', 'ovarian_small-cell_carcinoma', 'paediatric_high-grade_glioma', 'paediatric_low_grade_glioma', 'pan_glioma', 'pan-liver', 'pancreatic_cancer_(all_histologies)', 'pancreatic_ductal_adenocarcinoma', 'pancreatic_neoplastic_cysts', 'pancreatic_neuroendocrine_tumours', 'papillary_renal_cell_carcinoma', 'papillary_thyroid_cancer', 'parathyroid_carcinoma', 'penile_squamous_cancer', 'peripheral_T-cell_lymphoma', 'pheochromocytoma,_paraganglioma', 'prostate_cancer', 'renal_angiomyolipoma', 'renal_cancer_(all_histologies)', 'retinoblastoma', 'rhabdoid_tumour', 'rhabdomyosarcoma', 'salivary_gland_adenocarcinoma', 'serous_endometrial_cancer', 'skin_basal_cell_carcinoma', 'small_cell_lung_cancer', 'soft_tissue_sarcoma', 'splenic_marginal_zone_lymphoma', 'squamous_head_and_neck_cancer', 'T-cell_leukemia/lymphoma', 'testicular_germ_cell_cancer', 'thymic_carcinoma', 'triple_negative_breast_cancer', 'uterine_carcinosarcoma', 'vascular_cancer']

tissueTypes = ['adrenal_gland', 'bladder', 'blood', 'bone', 'brain', 'breast', 'cervix', 'colorectal', 'esophagus', 'head_and_neck', 'hepatobiliary', 'kidney', 'lung', 'ovarian', 'pancreas', 'paratyhroid_gland', 'penis', 'peripheral_nervous_system', 'pleura', 'prostate', 'retina', 'skin', 'small_intestine', 'soft_tissue', 'stomach', 'testis', 'thymus', 'thyroid', 'uterus', 'uvea', 'vascular_system']

data = {}

types = cancerTypes
if (mode == TISSUE_MODE):
	types = tissueTypes

for type in types:
	print('Requesting ' + type + '...') 
	fmtdType = type.replace('_', ' ')
	data[fmtdType] = []
	
	ctObj = { 'cancerGenesWhat': 'OR', 'primarySitesWhat': 'OR', 'cancerTypesWhat': 'OR', 'cancerTypes[]': cancerType, 'FunctionalClassWhat': 'OR', 'Duplicability': 'no_filter', 'Connectivity': 'no_filter', 'miRNA': 'no_filter', 'essentiality': 'no_filter', 'advanced_search': 'advanced_search', 'Submit': 'Get list!' }
	page = requests.post(url, data = ctObj)

	if (page.status_code != 200):
		print('Could not fetch page at ' + url + '; response is ' + page.status_code)
		continue

	soup = BeautifulSoup(page.content, 'html.parser')
	body = soup.body
	page = body.find(id="page")
	pqList = page.find_all(class_="post_query")

	if len(pqList) == 0:
		print('Warning, ' + type + ' returned an empty list')
	
	for pq in pqList:
		gene = pq.find("i")
		data[fmtdType].append(gene.string)

with open('genes_by_' + mode + '_type_ncgv6.json', 'w') as outfile:
	json.dump(data, outfile)

print('completed creating file for all ' + mode + ' Types')
