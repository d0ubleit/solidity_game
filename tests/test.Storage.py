import tonos_ts4.ts4 as ts4
import os.path as path
from random import randrange

path =  path.abspath(path.join(__file__ ,"../../EverWar"))
sep = '------------------------------------'
print(sep)

########## Initialization ###########
eq = ts4.eq

ts4.init(path, verbose = False)

keypair = ts4.make_keypair()
exp_WGBMain_Addr = ts4.Address('0:1234567890123456789012345678901234567890123456789012345678901234')

test = ts4.BaseContract('WarGameStorage',
        ctor_params = dict(_WGBMain_Addr = exp_WGBMain_Addr), 
        keypair = keypair
    )

# #####################################
# #### Fill mappings via addToPlayersAliveList method
# exp_pubkey = 0x1000000000000000000000000000000000000000000000000000000000000010
# AddrByte = 0x1234567890123456789012345678901234567890123456789012345678900000
# helper_IDtoPub = {}
# exp_mapPubToID = {}
# exp_mapIDtoAddr = {}
# cnt = 1
# cntstop = 100
# while cnt <= cntstop:
#     #print(f'iteration {cnt}')
#     t_Addr = ts4.Address('0:'+ str(hex(AddrByte))[2:])
#     helper_IDtoPub[cnt] = exp_pubkey
#     exp_mapPubToID[exp_pubkey] = cnt
#     exp_mapIDtoAddr[cnt] = t_Addr
#     test.call_method('addToPlayersAliveList', {'playerPubkey': exp_pubkey, 'Base_Addr': t_Addr})
#     AddrByte += 15
#     exp_pubkey += 1
#     cnt += 1

# #####################################
# #### Test (assertion mappings and getPlayersAliveList method results)
# t_mapPubToID, t_mapIDtoAddr = test.call_getter('getPlayersAliveList')
# for i in t_mapIDtoAddr:
#     #print(f'{i} => {t_mapIDtoAddr[i]}')
#     assert eq(exp_mapIDtoAddr[i], t_mapIDtoAddr[i])
# print()
# for i in t_mapPubToID:
#     #print(f'{i} => {t_mapPubToID[i]}')
#     assert eq(exp_mapPubToID[i], t_mapPubToID[i])

# #####################################
# #### Test getStat
# exp_stat =  {'basesAlive': cntstop
#             }
# t_stat = test.call_getter('getStat')
# assert eq(exp_stat, t_stat)

# #####################################
# #### Test removeFromPlayersAliveList
# # num_deletes = 10
# # for i in range(num_deletes):
# #     randIndex = randrange(1, cntstop)
# #     if randIndex in helper_IDtoPub:
# #         nowPubkey = helper_IDtoPub[randIndex]
# #         test.call_method('removeFromPlayersAliveList', {'playerPubkey': nowPubkey})
# #         del exp_mapPubToID[nowPubkey]
# #         del exp_mapIDtoAddr[randIndex]
# #         del helper_IDtoPub[randIndex]
# #     else:
# #         i -= 1




exp_pubkey = 0x1000000000000000000000000000000000000000000000000000000000000010
AddrByte = 0x1234567890123456789012345678901234567890123456789012345678900000
AddrStr = ('0:'+ str(hex(AddrByte))[2:])
helper_IDtoPub = {}
exp_mapPubToID = {}
exp_mapIDtoAddr = {}
cnt = 1

t_Addr = ts4.Address(AddrStr)
helper_IDtoPub[cnt] = exp_pubkey
exp_mapPubToID[exp_pubkey] = cnt
exp_mapIDtoAddr[cnt] = t_Addr
# test.call_method('addToPlayersAliveList', {'playerPubkey': exp_pubkey, 'Base_Addr': t_Addr})


# data = {'id' = 10,'src' = t_Addr,'dst' = test.addr,'type' = 'external_call','value' = 1000000,'method' = 'addToPlayersAliveList','params' = {'playerPubkey': exp_pubkey, 'Base_Addr': t_Addr}})
data = {}
data['id'] = '1'
data['src'] = AddrStr
data['dst'] = test.addr.str()
data['msg_type'] = 'external_call'
data['timestamp'] = '123123123'
data['log_str'] = ''
data['value'] = 1000000
data['method'] = 'addToPlayersAliveList'
data['params'] = {'playerPubkey': exp_pubkey, 'Base_Addr': t_Addr}

message = ts4.Msg(data)
gas = ts4.dispatch_one_message
print(gas)

AddrByte = 0x123456789012345678901234567890123456789012345678901234567890AA
AddrStr = ('0:'+ str(hex(AddrByte))[2:])
t_Addr = ts4.Address(AddrStr)

data['id'] = '2'
data['src'] = AddrStr
data['dst'] = test.addr.str()
data['msg_type'] = 'external_call'
data['timestamp'] = '223123123'
data['log_str'] = ''
data['value'] = 1000000
data['method'] = 'addToPlayersAliveList'
data['params'] = {'playerPubkey': exp_pubkey+15, 'Base_Addr': t_Addr}

message = ts4.Msg(data)
ts4.dispatch_one_message()
# print(gas)
# readmsg = ts4.pop_msg()
# print(readmsg.src)

#####################################
#### Test (assertion mappings and getPlayersAliveList method results)
t_mapPubToID, t_mapIDtoAddr = test.call_getter('getPlayersAliveList')
for i in t_mapIDtoAddr:
    print(f'{i} => {t_mapIDtoAddr[i]}')
    #assert eq(exp_mapIDtoAddr[i], t_mapIDtoAddr[i])
print()
for i in t_mapPubToID:
    print(f'{i} => {t_mapPubToID[i]}')
    #assert eq(exp_mapPubToID[i], t_mapPubToID[i])

####################################
### Test removeFromPlayersAliveList
    # nowPubkey = helper_IDtoPub[randIndex]
    # test.call_method('removeFromPlayersAliveList', {'playerPubkey': nowPubkey})
    
