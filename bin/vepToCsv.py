#!/usr/bin/env python3

import sys
import pandas as pd
import re


def merge_dicts(dict_list):

	all_keys = [key for d in dict_list for key in d.keys()]
	merged_dict = {key: ['NA'] * len(dict_list) for key in all_keys}

	for idx, d in enumerate(dict_list):

		for key, value in d.items():
			if value in ['', '.']:
				value = "NA"

			merged_dict[key][idx] = value

	return merged_dict


def write_csv(merged_dict, output_file):

	max_length = max(len(v) for v in merged_dict.values())
	with open(output_file, 'w') as outFile:

		headers = merged_dict.keys()
		outFile.write(",".join(headers))

		for i in range(max_length):
			row = [merged_dict[key][i] if i < len(merged_dict[key]) else 'NA' for key in headers]
			outFile.write("\n" + ",".join(row))



def get_csq_headers(info_csq):

	pattern = r'Format:\s*([^"]+)'
	matchObj = re.search(pattern, info_csq)
	csq_headers = matchObj.group(1).split("|")
	return csq_headers


def parse_info(info, info_csq):

	info_fields = info.split(";")
	info_dict = {}

	for field in info_fields:
		if "=" not in field:
			info_dict[field] = "True"
		elif field.startswith("CSQ="):
			csq_strings = field[len("CSQ="):].split(',')
			csq_headers = get_csq_headers(info_csq)

			for idx, csq_string in enumerate(csq_strings):
				csq_values = csq_string.split('|')
				for header_idx, header in enumerate(csq_headers):
					key = f"CSQ.{header}.{idx+1}"
					value = csq_values[header_idx] if csq_values[header_idx] else 'NA'
					info_dict[key] = value
		else:
			key, value = field.split('=')
			info_dict[key] = value

	return info_dict


def parse_format(sample_format, sample_values, sample_headers):

	format_dict = {}

	if ':' in sample_format:
		format_headers = sample_format.split(':')

	for sample_name, values in zip(sample_headers, sample_values):
		value_list = values.split(':')
		for header, value in zip(format_headers, value_list):
			format_dict[f"{sample_name}.{header}"] = value

	return format_dict



if len(sys.argv) != 3:
	print(f"USAGE: python3 {sys.argv[0]} input_vcf output_file")

input_file = sys.argv[1]
output_file = sys.argv[2]


with open(input_file, 'r') as vcf:

	vcf_dicts = []

	for line in vcf.readlines():
		line = line.strip()

		if line.startswith("##INFO=<ID=CSQ"):
			info_csq = line

		if line.startswith("#CHROM"):
			sample_headers = list(line.split("\t")[9:])

		if not line.startswith("#"):
			entries = line.split("\t")
			vcf_dict = {
				'CHROM': entries[0],
				'POS': entries[1],
				'ID': entries[2],
				'REF': entries[3],
				'ALT': entries[4],
				'QUAL': entries[5],
				'FILTER': entries[6],
			}

			info = entries[7]
			info_dict = parse_info(info, info_csq)
			vcf_dict.update(info_dict)

			if len(entries) > 8:
				sample_format = entries[8]
				sample_entries = list(entries[9:])
				format_dict = parse_format(sample_format, sample_entries, sample_headers)
				vcf_dict.update(format_dict)

			vcf_dicts.append(vcf_dict)


output_dict = merge_dicts(vcf_dicts)
write_csv(output_dict, output_file)
