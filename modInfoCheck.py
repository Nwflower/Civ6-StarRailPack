import os
import xml.etree.ElementTree as ET
from glob import glob

def is_folder_empty(folder_path):
    """检查文件夹是否为空"""
    try:
        # 检查文件夹中是否有文件或子文件夹
        return len(os.listdir(folder_path)) == 0
    except Exception as e:
        print(f"检查文件夹 {folder_path} 时出错: {e}")
        return False


def get_files_and_empty_folders(root_dir, exclude_files):
    """获取指定目录下所有文件和空文件夹的相对路径，排除指定文件"""
    items = set()

    for dirpath, dirnames, filenames in os.walk(root_dir):
        # 处理空文件夹
        for dirname in dirnames:
            dir_path = os.path.join(dirpath, dirname)
            if is_folder_empty(dir_path):
                rel_path = os.path.relpath(dir_path, root_dir)
                # 统一路径分隔符为正斜杠
                rel_path = rel_path.replace(os.sep, '/')
                items.add(rel_path)

        # 处理所有文件（排除指定文件）
        for filename in filenames:
            file_path = os.path.join(dirpath, filename)
            rel_path = os.path.relpath(file_path, root_dir)
            # 统一路径分隔符为正斜杠
            rel_path = rel_path.replace(os.sep, '/')

            # 检查是否为要排除的文件
            if rel_path not in exclude_files:
                items.add(rel_path)

    return items


def get_modinfo_files_and_actions(modinfo_path):
    """从modinfo文件中提取Files节点和操作节点下的所有文件路径"""
    try:
        tree = ET.parse(modinfo_path)
        root = tree.getroot()

        # 查找Files节点
        files_node = root.find('Files')
        mod_files = set()
        if files_node is not None:
            # 提取所有File节点的文本内容
            for file_node in files_node.findall('File'):
                file_path = file_node.text.strip() if file_node.text else ''
                if file_path:
                    mod_files.add(file_path)

        # 查找操作节点（FrontEndActions和InGameActions）
        action_files = set()

        # 处理FrontEndActions节点
        front_end_actions = root.find('FrontEndActions')
        if front_end_actions is not None:
            for action in front_end_actions.findall('*'):
                for file_node in action.findall('File'):
                    file_path = file_node.text.strip() if file_node.text else ''
                    if file_path:
                        action_files.add(file_path)

        # 处理InGameActions节点
        in_game_actions = root.find('InGameActions')
        if in_game_actions is not None:
            for action in in_game_actions.findall('*'):
                for file_node in action.findall('File'):
                    file_path = file_node.text.strip() if file_node.text else ''
                    if file_path:
                        action_files.add(file_path)

        return mod_files, action_files
    except Exception as e:
        print(f"解析modinfo文件时出错: {e}")
        return set(), set()


def main():
    # 获取当前脚本的文件名（用于排除）
    script_filename = os.path.basename(__file__)
    # 获取当前目录下所有.modinfo文件
    modinfo_files = glob("*.modinfo")

    if not modinfo_files:
        print("未找到任何.modinfo文件")
        return

    # 准备要排除的文件列表（modinfo文件和脚本本身）
    exclude_files = set(modinfo_files)
    exclude_files.add(script_filename)
    # 转换为相对路径格式（统一使用正斜杠）
    exclude_files = {f.replace(os.sep, '/') for f in exclude_files}

    # 获取当前目录下所有文件和空文件夹的相对路径（排除指定文件）
    current_dir = os.getcwd()
    all_actual_items = get_files_and_empty_folders(current_dir, exclude_files)

    # 从所有modinfo文件中收集列出的文件和操作引用的文件
    all_mod_files = set()
    all_action_files = set()
    for modinfo_file in modinfo_files:
        print(f"正在处理: {modinfo_file}")
        mod_files, action_files = get_modinfo_files_and_actions(modinfo_file)
        all_mod_files.update(mod_files)
        all_action_files.update(action_files)

    # 计算差异
    # 1. 实际存在但modinfo未列出的文件/空文件夹
    existing_not_listed = all_actual_items - all_mod_files
    # 2. modinfo列出但实际不存在的文件/文件夹
    listed_not_existing = all_mod_files - all_actual_items
    # 3. 加载过程中引用但未在Files中列出的文件
    action_not_in_files = all_action_files - all_mod_files

    # 输出结果
    print("\n=== 检查结果 ===")

    print("\n1. 实际存在但modinfo未列出的文件或空文件夹:")
    if existing_not_listed:
        for item in sorted(existing_not_listed):
            print(f"  - {item}")
    else:
        print("  无")

    print("\n2. modinfo列出但实际不存在的文件或文件夹:")
    if listed_not_existing:
        for item in sorted(listed_not_existing):
            print(f"  - {item}")
    else:
        print("  无")

    print("\n3. 加载过程中引用但未在Files中列出的文件:")
    if action_not_in_files:
        for item in sorted(action_not_in_files):
            print(f"  - {item}")
    else:
        print("  无")


if __name__ == "__main__":
    main()