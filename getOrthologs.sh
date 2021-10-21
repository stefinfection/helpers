#!/bin/bash
#given a human gene symbol and species ids, returns ensembl gene ids
#for orthologs corresponding to provided species ids, if they exist.
#if no species ids provided, just pulls back zebrafish, mouse, and human.
#if no orthologs could be found, returns empty string.
#SJG updated Oct2021

#args
gene=$1
species_ids=$2
api_key=$3

runDir=$PWD
tempDir=$(mktemp -d)
cd $tempDir

#consts
zebrafish_id="7955"
mouse_id="10090"
human_id="9606"
eutils_prefix="https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=gene&retmode=json&term=(9606\[Taxonomy%20ID\]%20AND%20("
odb_prefix="https://www.orthodb.org/"
eukaryota_tax_id=2759
uniprot_prefix="https://www.uniprot.org/uploadlists/?from=ACC+ID&to=ENSEMBL_ID&format=list&query="

#if no user-specified species, default to below
if [ -z "$species_ids" ]
then
  species_ids="${zebrafish_id},${mouse_id},${human_id}"
fi

#if no user-specified api key, use gene's
if [ -z "$api_key" ]
then
  api_key="NNN"
fi

#get ncbi gene id
gene_url="${eutils_prefix}${gene}\[Pref\]))&api_key=${api_key}"
ncbi_ids=$(curl -s "$gene_url" | jq -r '.esearchresult .idlist' | jq -r '.[]')
ncbi_arr=($ncbi_ids)
if ((${#ncbi_arr[@]} > 1));
then
  echo "warning: multiple ncbi ids for provided gene, using first one: ${ncbi_arr[0]}"
fi
first_id=${ncbi_arr[0]}

#get clusters according to ncbi gene_id
search_url="${odb_prefix}search?ncbi=1&query=${first_id}&level=${eukaryota_tax_id}"
cluster_ids=$(curl -s "$search_url" | jq -r '.data' | jq -r '.[]')
cluster_arr=($cluster_ids)
if ((${#cluster_arr[@]} > 1));
then
  echo "warning: multiple ortholog ids for provided gene, using first one: ${cluster_arr[0]}"
fi
first_cid=${cluster_arr[0]}

#get uniprot ids from ortholog payload
ortho_url="${odb_prefix}orthologs?id=${first_cid}&species=${species_ids}"
ortho_payld=$(curl -s "$ortho_url")
uniprot_ids=$(echo $ortho_payld | jq -r '.data' | jq -r '.[]' | jq -r '.genes' | jq -r '.[]' | jq -r '.uniprot .id')
uniprot_ids=($uniprot_ids)

#convert uniprot ids to ensembl ids & print to stdout
convert_url=$uniprot_prefix
for i in "${uniprot_ids[@]}"
do
  convert_url="${convert_url}${i},"
done
convert_url=${convert_url::-1}
ensem_ids=$(curl -L -s "$convert_url")
echo $ensem_ids

rm -rf $tempDir
cd $runDir
