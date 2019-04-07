total = 0
bits_extracted = 20*8
extract_more = {}

def collectParseNodes(node, state):
  for call in node.call_sequence:
    if call[0].value not 'extract':
      print("ERROR: unsupported call %s" % call[0].value)
      exit()
    for field in call[1].fields:
      total += field.width
  if total > bits_extracted:
    # register need to extract_more
    extract_more[(node.name, state)] = total
  else:
    extract_more[(node.name, state)] = 0
  
