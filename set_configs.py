#! /usr/bin/env python

import argparse
import re

def parse_cmd():
    parser = argparse.ArgumentParser(description='modifies serverconfig.xml with'
          ' variables stored in another file')
    parser.add_argument('serverconfig', metavar='[Serverconfig Path]',
          type=str, help='path of serverconfig xml file')
    parser.add_argument('configoptions', metavar='[Config Changefile]',
          type=str, help='path of file with config changes')
    
    return parser.parse_args()

def build_config_dict(config_file):
    config_dict = dict()
    with open(config_file) as fin:
        for line in fin:
            if '=' in line:
                d=line.strip().split('=')
                config_dict[d[0]]=d[1]
    return config_dict



def update_config(server_config_file, config_dict):
    property_matcher = re.compile('property name="(?P<property>.*)"\s*value="(?P<value>.*)"')
    output = []
    with open(server_config_file) as fin:
        for line in fin:
            match = property_matcher.search(line)
            if match:
                property = match.group('property')
                value = match.group('value')
                if property in config_dict.keys():
                    new_value = config_dict[property]
                    if value == new_value:
                        output.append(line)
                    else:
                        print 'Changing {} from "{}" to "{}"'.format(
                            property, value, new_value )
                        newline = re.sub('value=".*"',
                            'value="{}"'.format(new_value), line)
                        output.append(newline)
                else:
                    output.append(line)
            else:
                output.append(line)

    with open(server_config_file, 'w') as fout:
        fout.write(''.join(output))


    
def main():
    args = parse_cmd()
    print args.serverconfig
    print args.configoptions
    config_dict = build_config_dict(args.configoptions)
    update_config(args.serverconfig, config_dict)


if __name__ == '__main__':
    main()

