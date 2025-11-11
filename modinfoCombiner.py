from bs4 import BeautifulSoup
import xml.etree.ElementTree as ET
import os
import re
from xml.dom import minidom

target_file = "file.xml"
ModInfoName = "Team PVP Star Rail Pack.modinfo"

ModId = "DF0E3C1A-E572-1868-FBE9-C58E0671151F"
ModVersion = "1111"
ModName = "Team PVP [COLOR:ResCultureLabelCS]次元破壁：星穹铁道[ENDCOLOR]"
ModDescription = "这是以崩坏：星穹铁道世界观为背景的文明6模组整合包。"
ModTeaser = "愿此行，终抵群星"


def get_mod_folders():
    result = []
    for dirpath, dir_names, filenames in os.walk('../次元破壁：星穹铁道'):
        if target_file in filenames:
            rel_path = os.path.relpath(dirpath, '.')
            result.append(rel_path)
            dir_names[:] = []
    return result


def format_xml(xml_string, indent="\t"):
    try:
        root = ET.fromstring(xml_string)
        rough_string = ET.tostring(root, 'utf-8')
        reparsed = minidom.parseString(rough_string)
        pretty_xml = reparsed.toprettyxml(indent=indent)
        lines = [line for line in pretty_xml.split('\n') if line.strip() != '']
        return '\n'.join(lines)
    except Exception as e:
        return xml_string


def combine_modinfo_files():
    mod_cnt = 1
    files_dict = {}
    new_mod_dict = {}
    special_thanks_dict = {}
    author_dict = {}
    for mod in get_mod_folders():
        mod_info_path = os.path.join(mod, target_file)
        if os.path.exists(mod_info_path):
            with open(mod_info_path, 'r', encoding='utf-8') as file:
                data = file.read()
            bs_data = BeautifulSoup(data, "xml")

            file_tags = bs_data.find_all("File")
            for b in file_tags:
                if b.string in files_dict:
                    print(f'same file name used in {mod} and {files_dict[b.string]}: {b.string}')
                b.string = f'{mod}/{b.string}'

            lua_replace_tags = bs_data.find_all("LuaReplace")
            for b in lua_replace_tags:
                print(f'LuaReplace tag: {b}')
                b.string = f'{mod}/{b.string}'

            for b in file_tags:
                files_dict[b.string] = mod
            for b in lua_replace_tags:
                files_dict[b.string] = mod

            load_order_tags = bs_data.find_all("LoadOrder")
            for b in load_order_tags:
                b.string = f'{mod_cnt}{b.string}'

            author_tags = bs_data.find_all("Authors")
            for tag in author_tags:
                delimiters = r'[;,\s]+'
                for author in re.split(delimiters, tag.string):
                    author_dict[author] = 1

            special_thanks_tags = bs_data.find_all("SpecialThanks")
            for tag in special_thanks_tags:
                delimiters = r'[;,\s]+'
                for author in re.split(delimiters, tag.string):
                    special_thanks_dict[author] = 1

            for b in bs_data.find('Mod'):
                if b.name == 'Properties' or b.name == 'Dependencies' or b.name == None:
                    continue
                if b.name not in new_mod_dict:
                    new_mod_dict[b.name] = ''
                new_mod_dict[b.name] = new_mod_dict[b.name] + str(b) + '\n'
        mod_cnt = mod_cnt + 1
    sorted_authors = sorted(author_dict.keys(), key=lambda item: item)
    sorted_special_thanks = sorted(special_thanks_dict.keys(), key=lambda item: item)
    extra_dependencies = {
        "1B28771A-C749-434B-9053-D1380C553DE9": "LOC_EXPANSION1_MOD_TITLE",
        "4873eb62-8ccc-4574-b784-dda455e74e68": "LOC_EXPANSION2_MOD_TITLE",
    }
    dependencies_string = ''
    for key, value in extra_dependencies.items():
        dependencies_string += f'    <Mod id="{key}" title="{value}"/>\n'
    new_mod_info_string = f'''<?xml version="1.0" encoding="UTF-8"?>
<Mod id="{ModId}" version="{ModVersion}">
  <Properties>
    <Name>{ModName}</Name>
    <Description>{ModDescription}</Description>
    <Teaser>{ModTeaser}</Teaser>
    <Authors>{', '.join([f'{{{item}}}' if item.startswith('LOC_') else item for item in sorted_authors])}</Authors>
    <SpecialThanks>{', '.join([f'{{{item}}}' if item.startswith('LOC_') else item for item in sorted_special_thanks])}</SpecialThanks>
    <CompatibleVersions>1.2,2.0</CompatibleVersions>
  </Properties>\n'''
    new_mod_info_string += f'<Dependencies>\n{dependencies_string}</Dependencies>\n'
    for key, value in new_mod_dict.items():
        new_mod_info_string += ''.join(value).replace(f'</{key}>\n<{key}>', '').replace(f'>\n<', '>\n\t<')
    new_mod_info_string += '</Mod>'
    with open(ModInfoName, 'w', encoding='utf-8') as file:
        file.write(format_xml(new_mod_info_string))


if __name__ == "__main__":
    print("Combining modinfo files...")
    combine_modinfo_files()
