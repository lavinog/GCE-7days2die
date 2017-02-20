"""
Player.ttp file reader.
Based on Karlovsky120's 7DaysProfileEditor
https://github.com/Karlovsky120/7DaysProfileEditor

Work in progress
"""


from struct import *

# replace with file to read (I currently have this hardcoded while testing.)
FILE=r'XXXXXXXXXXXXXXXXX.ttp'

class BinaryReader(object):
  def __init__(self, buffer_object):
    self.buffer_object=buffer_object

  def ReadChar(self):
    return unpack('c', self.buffer_object.read(1))[0]

  def ReadByte(self):
    return unpack('c', self.buffer_object.read(1))[0]

  def ReadBytes(self, n):
    return self.buffer_object.read(n)

  def ReadInt32(self):
    return unpack('i', self.ReadBytes(4))[0]

  def ReadSingle(self):
    return unpack('f', self.ReadBytes(4))[0]
    
  def ReadBoolean(self):
    return unpack('?', self.ReadBytes(1))[0]

class StreamReader(object):
  def __init__(self, binary_reader_object):
    self.br = binary_reader_object

  def Read(self):
    pass
  

class Vector3D(object):
  def __repr__(self):
    return '{}, {}, {}'.format(self.x, self.y, self.z)

class BodyDamage(StreamReader):
  def Read(self):
    pass

class EntityCreationData(StreamReader):
  def Read(self):
    br = self.br
    self.entityCreationDataVersion = br.ReadByte()
    self.entityClass = br.ReadInt32()
    self.eid = br.ReadInt32()
    self.lifetime = br.ReadSingle()
    self.pos = Vector3D()
    self.pos.x = br.ReadSingle()
    self.pos.y = br.ReadSingle()
    self.pos.z = br.ReadSingle()

    self.rot = Vector3D()
    self.rot.x = br.ReadSingle()
    self.rot.y = br.ReadSingle()
    self.rot.z = br.ReadSingle()

    self.onGround = br.ReadBoolean()

    self.bodyDamage = BodyDamage(br)
    self.bodyDamage.Read()



class PlayerData(object):
  def __init__(self, filename):
    self.filename=filename
   
  def Read(self):
    with open(self.filename, 'rb') as fin:
      self.br = br = BinaryReader(fin)
      self.header = unpack('cccc', self.br.ReadBytes(4))
      self.saveFileVersion = self.br.ReadChar()

      self.ecd = EntityCreationData(br)
      self.ecd.Read()





pd = PlayerData(FILE)
pd.Read()
  
print(int(pd.ecd.eid))
print(pd.ecd.pos)
print(pd.ecd.onGround)
  

  
