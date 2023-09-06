import commands
import json
# import pdb
import signal
import sys
import time
import numpy
import os
'''
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
import pickle
'''

# Version 3.0.0
# Nov 19, 2019

# close_connection_time=2

def hang_handler(signum, frame):
    raise TimeoutException()



def debug (id,event1):
    if ev_s_id == str(id):
        print ("ev:",event1)
# -----------------

def indexa (netlog_trimmed):

    #Almacena urls,jobs,h2s,socks
    lista_tot={"urls":{"list":{},"t":2,"st":1},"jobs":{"list":{},"t":139,"st":15},"jobs_cntl":{"list":{},"t":152,"st":24},"h2s":{"list":{},"t":181,"st":9},"socks":{"list":{},"t":34,"st":8},"socks_udp":{"list":{},"t":34,"st":17}}
    open_urls={}
    for event1 in netlog_trimmed:
        ev_s_id= str(event1["source"]["id"]) #forzar clave tipo string para diccionario
        ev_s_type= event1["source"]["type"]
        
        for dict in lista_tot.values():
            if event1["type"] == dict["t"] and ev_s_type == dict["st"]:
                #Begin or End of a block
                #BEGIN
                if event1["phase"] == 1:
                    #Begin
                    dict["list"][ev_s_id]=[event1]
                    open_urls[ev_s_id]= True
                #END
                elif event1["phase"] == 2:
                    if open_urls[ev_s_id]:
                        dict["list"][ev_s_id].append (event1)
                        open_urls[ev_s_id]= False
                    else:
                        warning ("ev_s_id:"+ev_s_id+" block is closed. a new close arrived:",event1)
                else:
                    warning ("block with unexpected phase:"+str(event1["phase"]),event1)
                break
            # event contained in block
            elif ev_s_id in dict["list"]:
                dict["list"][ev_s_id].append (event1)
                if not open_urls[ev_s_id]:
                    warning ("ev_s_id:"+ev_s_id+" block is closed. event arrived:",event1)
                break

    #Check unclosed blocks
    for openurl,key in zip(open_urls,open_urls.keys()):
        if open_urls[key]:
            warning ("url:"+openurl+" no cerrado:",key, )
    
    print ("----- JOBS ------")
    print (lista_tot["jobs"]["list"].keys())

    print ("----- SOCKS ------")
    print (lista_tot["socks"]["list"].keys())

    return (lista_tot)

def get_conex_info (netlog_name,conexiones_name):
    
    global d
    d=False
    print "Activa debug..",d
    #Almacenamos el equivalente al DOM (dirs y mime_list)
    l_conexiones={}
    
    #Lee netlog
    with open(netlog_name, 'r') as f2:
        netlog = json.load(f2)
    netlog_trimmed= netlog["events"]
    
    lista_tot=indexa (netlog_trimmed)


    # Analisis de cada url
    for url in lista_tot["urls"]["list"].keys():
        c_url=lista_tot["urls"]["list"][url]
        #d= True if url == "124" else False
        d=False
        try:
            el_URL=c_url[0]['params']['url']
            if d: print "\n++ URL:",url,el_URL," >>:",c_url[0]
            #BEGIN_REQ_ALIVE
            if c_url[0]["type"] != 2 or c_url[0]["phase"] != 1:
                raise Runout_Exception ("no empieza por REQ_ALIVE [2,1]: "+str(c_url[0]))
            c_url=c_url[1:]
            
            #BEGIN URL_REQ_START_JOB, END_REQ_ALIVE
            c_url=saltaL (c_url,[[97,1],[2,2]])
            
            while c_url[0]["type"] == 97:
            
                # Procesa HTTP_STREAM_REQUEST
                c_url=salta (c_url,138,1)
                # Salta a HTTP_STREAM_JOB_CONTROLLER
                c_url=salta(c_url,153,0)
                #id_st_job_cnt=c_url[0]["source"]["id"]
                
                id_st_job_cnt=str(c_url[0]["params"]["source_dependency"]["id"])
                if d: print ("id_st_job_cnt",id_st_job_cnt)
                #if d: print (lista_tot["jobs"]["list"][id_st_job])
                job_cnt=lista_tot["jobs_cntl"]["list"][id_st_job_cnt]
                job_cnt=salta(job_cnt,141,0)
                if d: print ("job_cnt",job_cnt)
                id_st_job_1=str(job_cnt[0]["params"]["source_dependency"]["id"])
                if d: print ("id_st_job",id_st_job_1)
                #if d: print ("id_st_job",id_st_job_1)
                id_st_job=id_st_job_1
                '''
                # Salta a STREAM_JOB
                c_url=salta(c_url,145,0)
                id_st_job=str(c_url[0]["params"]["source_dependency"]["id"])
                if d: print ("id_st_job",id_st_job)
                if id_st_job != id_st_job_1:
                    msg= "diferentes "+str(id_st_job)+" "+str(id_st_job_1)
                    warning2 (msg)
                '''
                
                dirs=get_dirs_from_Stream_Job (lista_tot["jobs"]["list"][id_st_job],lista_tot)
                # End HTTP_STREAM_REQUEST
                c_url=salta(c_url,138,2)
                #c_url=c_url[1:]

                #BEGIN HTTP_TRANSACTION_SEND_REQ
                c_url=salta(c_url,159,1)
                # HTTP_SEND_REQ_HEADER o HTTP2_SEND_REQ_HEADER
                c_url=saltaL(c_url,[[160,0],[162,0]])
                #url= get_url (c_url[0])
                #END HTTP_TRANSACTION_SEND_REQ
                c_url=salta(c_url,159,2)
                #c_url=c_url[1:]

                #BEGIN HTTP_TRANSACTION_READ_HEADER
                c_url=salta(c_url,164,1)
                # HTTP_SEND_REQ_HEADER o HTTP2_SEND_REQ_HEADER
                c_url=salta(c_url,165,0)
                status,contentType,contentLength= get_response (c_url[0])
                gen_info (dirs,status,contentType,contentLength,l_conexiones,el_URL)
                #END HTTP_TRANSACTION_READ_HEADER
                c_url=salta(c_url,164,2)
                #c_url=c_url[1:]

                #END URL_REQ_START_JOB
                c_url=salta (c_url,97,2)
                c_url=c_url[1:]

                #BEGIN URL_REQ_START_JOB, END_REQ_ALIVE
                c_url=saltaL (c_url,[[97,1],[2,2]])

            #END_REQ_ALIVE
            if not (c_url[0]["type"] == 2 and c_url[0]["phase"] ==2 and len(c_url)==1):
                raise Runout_Exception ("no acaba por REQ_ALIVE [2,2]: "+str(c_url[0]))
            else:
                if d: print "-- URL",el_URL," OK"
                
        except Runout_Exception as e:
            #warning2 ("Salto exception. URL: "+el_URL)
            warning ("Salto exception. URL: "+el_URL,e)

        d= False
    #dump conexiones
    print ("\n--- conexiones ----")
    for key in l_conexiones:
        print (">> ",key, "<<", l_conexiones[key])

    with open(conexiones_name, 'w') as f:
        for key in l_conexiones:
            #line= str(key)+ " "+ l_conexiones[key]
            msg=""
            for i in key:
                msg+= str(i)+" "
            for k,v in l_conexiones[key].iteritems():
                msg+= str(k)+":"+str(v)+" "
            print >> f, msg
            #print(msg, file=f)
    f.close()

# -------------------------

def get_dirs_from_Stream_Job (job_ses,lista_tot):
    c_job=job_ses
    #print ("saltaL en get_dirs")
    #c_job=saltaL (c_job,[[95,0],[208,0]])
    c_job=saltaL (c_job,[[95,0],[208,0],[209,0]])
    if c_job[0]["type"] == 95:
        #socket
        return get_dirs_from_Socket (lista_tot["socks"]["list"][str(c_job[0]["params"]["source_dependency"]["id"])],lista_tot)
    #elif c_job[0]["type"] == 208:
    elif c_job[0]["type"] in [208,209]:
        # http2 ses
        return get_dirs_from_HTTP2 (lista_tot["h2s"]["list"][str(c_job[0]["params"]["source_dependency"]["id"])],lista_tot )
    else:
        warning ("get_dirs_from_Stream_JOB: no socket or http2 sess.",job)
        return None

def get_dirs_from_HTTP2 (http2_ses,lista_tot):
    c_h2=http2_ses
    c_h2= saltaL (c_h2,[[182,0]])
    if c_h2[0]["type"] == 182:
        #socket
        return get_dirs_from_Socket (lista_tot["socks"]["list"][str(c_h2[0]["params"]["source_dependency"]["id"])],lista_tot)
    else:
        warning ("get_dirs_from_HTTP2: no socket",http2_ses)
        return None

def get_dirs_from_Socket (socket_ses,lista_tot):
    c_sock=socket_ses
    c_sock= saltaL(c_sock,[[36,1]])
    dst_add=c_sock[0]["params"]["address"]
    c_sock= saltaL(c_sock,[[35,2]])
    src_add=c_sock[0]["params"]["source_address"]
    return src_add+" "+dst_add

def gen_info (dirs,status,contentType,contentLength,conexiones,el_URL):
    
    dirs=dirs.split(" ")
    #print (len(dirs))
    src=dirs[0].split(":")
    dst=dirs[1].split(":")
    #print (dirs)
    mimeType=get_content(status,contentType,contentLength)
    msg=src[0]+" "+src[1]+" "+dst[0]+" "+dst[1]+" "+mimeType + " "+ el_URL
    print (">>> "+msg)
    
    # meter en array conexiones
    key=(src[0], src[1], dst[0], dst[1] )
    if not key in conexiones:
        conexiones[key]={}
    if not mimeType in conexiones[key]:
        conexiones[key][mimeType]=0
    conexiones[key][mimeType]+=1
    
    return

def get_content(status,contentType,contentLength):
    status=int(status)
    msg=""
    if status ==200:
        msg_add= "_0" if contentLength == 0 else ""
        msg=contentType+msg_add
    elif status >= 300 and status <400:
        msg_add= "_"+contentType if contentLength > 0 else ""
        msg="Red"+msg_add
    else:
        msg_add= ":"+contentType if contentLength > 0 else ""
        msg="Oth_"+str(status)+msg_add
    return msg

# -------------------------

#status,contentType,ContentLength= get_response (c_url[0])
def get_response (ev_165):
    headers=ev_165["params"]["headers"]
    #print ("headers:", headers)
    resp=headers[0].split(" ")
    status=int(resp[1])
    
    content_length=0
    content_type=""
    headers= headers[1:]
    for h in headers:
        hh= h.lower().split (":")
        if hh[0] == "content-length":
            #print ("hh:",hh)
            content_length=int(hh[1])
        elif hh[0] == "content-type":
            content_type=hh[1].split(";")[0].strip().encode ('ascii','ignore')

    return status,content_type,content_length

# -------------------------

class Runout_Exception (Exception):
    pass


def salta (c_url,limite,phase):
    #print ("salta",limite,phase)
    return saltaL (c_url,[[limite,phase]])

def saltaL (c_url,blocks):
    
    if d: print ("saltaL",blocks)
    for i in range(len(c_url)):
        for j in range(len(blocks)):
            #if d: print ("c_url[i]",c_url[i])
            #if d: print ("blocks[j][0]",blocks[j][0])
            if c_url[i]["type"] == blocks[j][0]:
                if c_url[i]["phase"]== blocks[j][1]:
                    return c_url[i:]
                else:
                    raise Runout_Exception ("saltaL phase does not match."+str(c_url[i])+" block/phase:"+str(blocks[j]))
        
    raise Runout_Exception ("saltaL limit: "+str(blocks)+ " not found" )
    return None

# -----------

def xget_dirs_from_Stream_Job (netlog_trimmed,id_st_job_cnt,id_st_job):

    # Primero desde HTTP_STREAM_JOB/145
    search1= [ [15,[95]] ]
    search2= [ [15,[211,208,209]], [9,[182]] ]
    dirs=search_dirs (id_st_job,netlog_trimmed,[search1,search2])
    if dirs != None:
        return dirs
    
    # Segundo desde HTTP_STREAM_JOB_CONTROLLER/153
    search3= [ [24,[141]], [15,[95]] ]
    search4= [ [24,[141]], [15,[211,208,209]], [9,[182]] ]
    dirs=search_dirs (id_st_job,netlog_trimmed,[search1,search2])
    if dirs != None:
        return dirs

    raise Runout_Exception ("no encontrado dirs de socket."+str(c_url[i])+" block/phase:"+str(blocks[j]))

    
def search_dirs (id_st_ev,netlog_trimmed,camino):

    search1= [ [1,[145]], [15,[95]] ]
    
    l_event1_s_ids= search_URL_Req (p_url,netlog_trimmed)
    if len(l_event1_s_ids) > 0:
        search1= [ [1,[145]], [15,[95]] ]
        #search2= [ [1,[145]], [15,[211,208]], [9,[182]] ]
        search2= [ [1,[145]], [15,[211,208,209]], [9,[182]] ]
        search3= [ [1,[153]], [24,[141]], [15,[95]] ]
        search4= [ [1,[153]], [24,[141]], [15,[211,208,209]], [9,[182]] ]
        search5= [ [1,[153]], [24,[141]], [15,[211,208,209]], [9,[182]] ]
        caminos= [search1,search2,search3,search4,search5]
    else:
        # try with STREAM_JOB_CONTROLLERs
        warning ("printDOM. Usando Stream_JobControllers para url inicial",p_url)
        l_event1_s_ids= search_Stream_JobController (p_url,netlog_trimmed)
        if len(l_event1_s_ids) >1:
            warning ("printDom. varios jobcontrollers para 1 url",l_event1_s_ids)
        search1=[ [24,[141]], [15,[211,208,209]], [9,[182]] ]
        caminos= [search1]
    
    #print ("## evento orig:",l_event1_s_ids)
    
    # Busca en el grafo por diversos caminos hasta llegar al socket
    l_ports=[]
    for event1_s_id in l_event1_s_ids:
        port=search_port (event1_s_id,netlog_trimmed,caminos)
        if port != None:
            l_ports.append(port.encode ('ascii','ignore'))

def diferentes (lista):
    if len(lista) == 0:
        return False
    else:
        for i in range(len(lista)-1):
            if lista[0]!= lista[i+1]:
                return True
        return False

def get_src_port(event_s_id):
    sock_event= None
    for eventf in netlog_trimmed:
        if "params" in eventf  and "source_address" in eventf["params"] and \
           eventf ["source"]["type"]== 8 and eventf["type"] == 35 and \
           eventf ["source"]["id"] == event_s_id :
            sock_event= eventf

    if sock_event!=None:
        #print ("## encontrado_fin:",event_s_id,sock_event)
        source_address = sock_event["params"]["source_address"]
        s_port = (source_address.split(":"))[1]
        return s_port
    else:
        warning ("src_port. no client address/port found for",event_s_id)
        return None

    return None

def search_sockid (event1_s_id,netlog_trimmed,caminos):

    # Busca en el grafo por diversos caminos hasta llegar al socket
    
    l_dircli=[]
    for s in caminos:
        #print ("## Testing path:",s)
        event_s_id =search_path (event1_s_id,s,netlog_trimmed)
        if event_s_id!= None:
            l_dircli.append(event_s_id)
    
    if len(l_dircli) == 0:
        return None
    else:
        if len(l_dircli) > 1 and diferentes(l_dircli):
            print ("## WARNING. several ids_ports for 1 url:",l_dircli)
        event_s_id= l_dircli[0]

        # Coge el puerto origen del socket
        #print ("## evento fin:", event_s_id)
        return get_src_port(event_s_id)




def search_path (event_s_id,path,netlog_trimmed):
    print ("## search path",path)
    #path=[[1,[153]],[24,[141]]]
    for step in path:
        print ("## Testing event: ",event_s_id,step)
        event_s_id,t=search_next (event_s_id,step,netlog_trimmed)
        print ("## new event in type: ",event_s_id,t)
        if event_s_id == None:
            return None
    return event_s_id


def search_next (event_s_id,tt,netlog_trimmed):
    print ("searching ",event_s_id)
    for event2 in netlog_trimmed:
        #print ("checking net_event",event2)
        if "params" in event2 and  "source_dependency" in event2["params"] and \
           event2 ["source"]["type"]== tt[0] and event2["type"] in tt[1] and \
           event2 ["source"]["id"] == event_s_id :
            print ("found:",event2)
            return event2["params"]["source_dependency"]["id"],event2["type"]
    return None,0

# ---------------


def search_URL_Req (p_url,netlog_trimmed):
    return search_url_from_start (p_url,netlog_trimmed,[1,2])

def search_Stream_JobController (p_url,netlog_trimmed):
    return search_url_from_start (p_url,netlog_trimmed,[24,152])


def search_url_from_start (p_url,netlog_trimmed,start):
    l_event1_ids=[]
    for event1 in netlog_trimmed:
        if "params" in event1 and "url" in event1["params"]:
            url_net_a=event1["params"]["url"]
            url_net_b=url_net_a.encode ('ascii','ignore')
            #print ("urls", url_net_a,url_net_b, "event source.t",event1["source"]["type"], "event type",event1["type"])
            if ( url_net_a == p_url or url_net_b == p_url ) and \
               event1["source"]["type"] == start[0] and event1["type"] == start[1]:
                #print ("event",event1)
                l_event1_ids.append(event1["source"]["id"])
    
    return l_event1_ids

# ---------------

'''
     f_sock_vacios = open(fname_socks_vacios, 'w')
    
    t_bytes_sent_or_received=[64,65,66,67]
    
    for event1 in netlog_trimmed:
        if event1["source"]["type"] == 8 and event1["type"] == 35 and "source_address" in event1["params"]:
            #print ("event1", event1)
            num_sock= event1["source"]["id"]
            src_addr= event1["params"]["source_address"].split(":")
            found_socket_in_use= False
            found_dst_addr= False
            found_HTTP_STREAM_JOB= False
            for event2 in netlog_trimmed:
                if event2["source"]["id"] == num_sock:
                    if event2["type"] == 38 and "params" in event2 and "source_dependency" in event2["params"] and "type" in event2["params"]["source_dependency"] and event2["params"]["source_dependency"]["type"]== 15:
                        found_HTTP_STREAM_JOB= True
                    elif found_HTTP_STREAM_JOB and event2["type"] in t_bytes_sent_or_received:
                        found_socket_in_use=True
                    elif event2["type"] == 36 and  "params" in event2 and "address" in event2["params"]:
                        found_dst_addr=True
                        dst_addr=event2["params"]["address"].split(":")
        
            if not found_socket_in_use:
                if not found_dst_addr:
                    dst_addr=["--","--"]
                    warning ("print_socks_vacios. socket vacio sin dst_addr",src_addr)
                    warning2 ("num sock:"+str(num_sock))
                print >> f_sock_vacios, (src_addr[0]+" "+src_addr[1]+" "+dst_addr[0]+" "+dst_addr[1])

    f_sock_vacios.close()
'''

def printDOM(log_perf_dict,netlog_name):

    global ip
    final_time = numpy.float64(time.time())
    
    # Lee Log_performance
    #with open(log_perf_name,'r') as f1:
    #    log_performance= json.load(f1)
    
    # Dump log_performance para analisis posterior en debug
    log_perf_name="log_performance"
    # En formato pickle
    with open(log_perf_name+".pkl",'wb') as f_log_pkl:
        pickle.dump(log_perf_dict,f_log_pkl, protocol=pickle.HIGHEST_PROTOCOL)
    f_log_pkl.close()

    #with open(log_perf_name+".json", 'wb') as f_log_json:
    #    json.dumps(log_perf_dict, f_log_json)

    # En formato json
    j= json.dumps(log_perf_dict, indent=2)
    f= open (log_perf_name+".json", "w")
    print >>f,j
    #print(j, file=f)
    f.close()
    
    #Lee netlog
    with open(netlog_name, 'r') as f2:
        netlog = json.load(f2)

    netlog_trimmed= netlog["events"]

    # Generate DOM
    #fich_dom_log = "dom_log_test.txt"
    fich_dom_log = "dom_logs/dom_" + str(os.getpid()) + "_" + str(initial_time) + "_" + str(final_time) + ".txt"
    f = open(fich_dom_log, 'w')

    print >> f, ("#c_ip:1 s_ip:2 s_port:3 time_init:4 time_fin:5 petition_url:6 mimeType:7 url_dom:8 c_port:9")

    conexiones={}
    redirects_302={}

    for p_entry in log_performance_dict:
        #print (p_entry)
        p_message = p_entry["message"]
        p_message_dict = json.loads(p_message)
        p_message_dict2 = p_message_dict["message"]
        p_mdict = p_message_dict2["params"]
        p_method = p_message_dict2["method"]
        
        #if ("response" in mdict):
        if p_method == "Network.responseReceived":
            p_response = p_mdict["response"]
            #print ("DOM: responseReceived.", p_entry)
            if "url" in p_response and "remoteIPAddress" in p_response and "remotePort" in p_response:
                p_url = p_response["url"]
                #print ("p_url:"+p_url)
                p_socket_id= p_response["connectionId"]
                
                if p_response["remoteIPAddress"] != "" and str(p_response["remotePort"]) != "0":
                    #print ("p_remoteIPAddress:",p_response["remoteIPAddress"])
                    #print ("p_remotePort:",p_response["remotePort"])
                    
                    mimeType= str(p_response["mimeType"])
                    mimeType= "---" if mimeType == "" else mimeType
                    
                    dom_line= ip + " " + str(p_response["remoteIPAddress"]) + " " \
                              + str(p_response["remotePort"]) + " " \
                              + str(initial_time).replace(".", "") + " " \
                              + str(final_time).replace(".", "") + " " \
                              + str(sys.argv[1]) + " " + mimeType + " " + p_url
                    
                    # Opcion 2
                    # Directo desde performance file cogiendo el connectionId -> socket Id en netlog
                    port= get_src_port (p_socket_id,netlog_trimmed)
                    
                    if port != None:
                        dom_line+= " " + str(port)
                    else:
                        warning ("printDOM, no hay port en url:", p_url)
                
                    print ("## dom line",dom_line)
                    print >> f, dom_line
                    
                    # meter en array conexiones
                    key=(ip,port,p_response["remoteIPAddress"],p_response["remotePort"])
                    if not key in conexiones:
                        conexiones[key]={}
                    if not mimeType in conexiones[key]:
                        conexiones[key][mimeType]=0
                    conexiones[key][mimeType]+=1
                else:
                    warning ("printDOM. no remoteIPAddress or remotePort in p_response",p_response)
            else:
                warning ("printDOM. no url or no remoteIPAddress or remotePort in p_response",p_response)
    
        elif p_method == "Network.requestWillBeSent" and \
             "redirectResponse" in p_mdict:
             # and "location" in p_mdict["redirectResponse"]:
            # Acumula redirects
            p_response = p_mdict["redirectResponse"]
            p_socket_id= p_response["connectionId"]
            port= get_src_port (p_socket_id,netlog_trimmed)
            key=(ip,port,p_response["remoteIPAddress"],p_response["remotePort"])
            if not key in redirects_302:
                redirects_302[key]=0
            redirects_302[key]+=1
            

    f.close()
    
    #dump conexiones
    print ("--- conexiones ----")
    for key in conexiones:
        print (">> ",key, "<<", conexiones[key])

    #dump redirects
    print ("--- redirects ----")
    for key in redirects_302:
        if key in conexiones:
            warning ("redirect en conexion",key)
        print (">> ",key, "<<", redirects_302[key])


def diferentes (lista):
    if len(lista) == 0:
        return False
    else:
        for i in range(len(lista)-1):
            if lista[0]!= lista[i+1]:
                return True
        return False


def get_src_port(event_s_id,netlog_trimmed):
    global ip
    sock_event= None
    for eventf in netlog_trimmed:
        if "params" in eventf  and "source_address" in eventf["params"] and \
           eventf ["source"]["type"]== 8 and eventf["type"] == 35 and \
           eventf ["source"]["id"] == event_s_id :
            sock_event= eventf

    if sock_event!=None:
        #print ("## encontrado_fin:",event_s_id,sock_event)
        source_address = sock_event["params"]["source_address"].split(":")
        if source_address[0] != ip :
            warning ("get_src_port. ips diferentes: global_ip:"+str(ip)+" socket_ip:"+str(source_address[0]))
        s_port = source_address[1]
        return s_port
    else:
        warning ("src_port. no client address/port found for",event_s_id)
        return None

    return None

def search_port (event1_s_id,netlog_trimmed,caminos):

    # Busca en el grafo por diversos caminos hasta llegar al socket
    
    l_dircli=[]
    for s in caminos:
        #print ("## Testing path:",s)
        event_s_id =search_path (event1_s_id,s,netlog_trimmed)
        if event_s_id!= None:
            l_dircli.append(event_s_id)
    
    if len(l_dircli) == 0:
        return None
    else:
        if len(l_dircli) > 1 and diferentes(l_dircli):
            warning ("search_port. several ids_ports for 1 url:",l_dircli)
        event_s_id= l_dircli[0]

        # Coge el puerto origen del socket
        #print ("## evento fin:", event_s_id)
        return get_src_port(event_s_id,netlog_trimmed)


def search_URL_Req (p_url,netlog_trimmed):
    #return search_url_from_start (p_url,netlog_trimmed,[1,2])
    return search_url_from_start (p_url,netlog_trimmed,[1,97])

def search_Stream_JobController (p_url,netlog_trimmed):
    return search_url_from_start (p_url,netlog_trimmed,[24,152])


def search_url_from_start (p_url,netlog_trimmed,start):
    l_event1_ids=[]
    for event1 in netlog_trimmed:
        if "params" in event1 and "url" in event1["params"]:
            url_net_a=event1["params"]["url"]
            url_net_a= url_net_a.split("#")[0]
            url_net_b=url_net_a.encode ('ascii','ignore')
            #print ("urls", url_net_a,url_net_b, "event source.t",event1["source"]["type"], "event type",event1["type"])
            if ( url_net_a == p_url or url_net_b == p_url ) and \
               event1["source"]["type"] == start[0] and event1["type"] == start[1]:
                #print ("event",event1)
                l_event1_ids.append(event1["source"]["id"])
    
    return l_event1_ids

def search_path (event_s_id,path,netlog_trimmed):
    #print ("## search path",path)
    #path=[[1,[153]],[24,[141]]]
    for step in path:
        #print ("## Testing event: ",event_s_id,step)
        event_s_id,t=search_next (event_s_id,step,netlog_trimmed)
        #print ("## new event in type: ",event_s_id,t)
        if event_s_id == None:
            return None
    return event_s_id


def search_next (event_s_id,tt,netlog_trimmed):
    #print ("searching ",event_s_id)
    for event2 in netlog_trimmed:
        #print ("checking net_event",event2)
        if "params" in event2 and  "source_dependency" in event2["params"] and \
           event2 ["source"]["type"]== tt[0] and event2["type"] in tt[1] and \
           event2 ["source"]["id"] == event_s_id :
            #print ("found:",event2)
            return event2["params"]["source_dependency"]["id"],event2["type"]
    return None,0

def warning (msg,aux):
    print ("### Warning. "+msg)
    print (" ##:"+str(aux)+":")
    
def warning2 (msg):
    print ("### Warning2. "+msg)



# -------------------

if len(sys.argv) !=3:
    print ("usage: "+sys.argv[0]+" netlog_file conexiones_file")
    exit (1)

netlog_name=sys.argv[1]
conexiones_name=sys.argv[2]

d=True
get_conex_info (netlog_name, conexiones_name)

#debug
d=False
'''

if len(sys.argv) !=3:
    print ("usage: "+sys.argv[0]+" link duration. ")
    exit (1)

link=sys.argv[1]
duration=int(sys.argv[2])

hang_timeout = 60

signal.signal(signal.SIGALRM, hang_handler)

signal.alarm(duration + hang_timeout)

netlog_name = 'net_logs/netlog_' + str(os.getpid()) + "_" + str(numpy.float64(time.time()))

options = webdriver.ChromeOptions()
# options.add_argument('headless')
options.add_argument('--log-net-log=' + netlog_name)

caps = DesiredCapabilities.CHROME
caps['loggingPrefs'] = {'performance': 'ALL'}
caps['pageLoadStrategy'] = 'normal'

browser = webdriver.Chrome(chrome_options=options, desired_capabilities=caps)
maxTimeWait = duration
browser.implicitly_wait(5)
browser.set_page_load_timeout(maxTimeWait)

ip = commands.getoutput("echo $(ifconfig ens4) | cut -d ' ' -f7 | cut -d ':' -f2")


try:
    print ("Loading ....")
    # pdb.set_trace()
    initial_time = numpy.float64(time.time())
    #driver.delete_all_cookies()
    # .decode('ascii').encode('ascii', 'ignore')
    browser.get(link)
    print("Visited page: " + browser.title.encode('ascii', 'ignore') + " (" + link + ").")
    time.sleep(duration);
    print (" Finalizada visita")
    # Pause
    x''
    browser.execute_script(
            'document.getElementsByTagName("video")[0].paused ?'
            'document.getElementsByTagName("video")[0].play() :'
            'document.getElementsByTagName("video")[0].pause();')
    x''
    final_time = numpy.float64(time.time())
    msg_err=""

except TimeoutException:
    msg_err="The page is not responding (" + link + ")."
except Exception as e:
    msg_err="Unexpected Error (" + str(e) + "). in link: "+link

log_performance_dict = browser.get_log('performance')

browser.close()
browser.quit()

printDOM(log_performance_dict,netlog_name)
print_sock_vacios ('socks_vacios.txt',netlog_name)

if msg_err != "":
    print ("ERROR:"+msg_err)
    exit(1)
else:
    exit(0)

'''
