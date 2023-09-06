import commands
import json
# import pdb
import signal
import sys
import time
import numpy
import os
from selenium import webdriver
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.common.desired_capabilities import DesiredCapabilities
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait
import pickle



# close_connection_time=2

def hang_handler(signum, frame):
    raise TimeoutException()




# -----------------

def print_sock_vacios(fname_socks_vacios,netlog_name):

    #Lee netlog
    with open(netlog_name, 'r') as f2:
        netlog = json.load(f2)
    netlog_trimmed= netlog["events"]

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
    print ("###:"+str(aux)+":")
    
def warning2 (msg):
    print ("### Warning2. "+msg)



# -------------------


if len(sys.argv) !=3:
    print ("usage: "+sys.argv[0]+" link duration. ")
    exit (1)

link=sys.argv[1]
duration=int(sys.argv[2])

print ("inicio de ", sys.argv[0], link, duration)
#hang_timeout = 60
hang_timeout = 300

#signal.signal(signal.SIGALRM, hang_handler)
#signal.alarm(duration + hang_timeout)

netlog_name = 'net_logs/netlog_' + str(os.getpid()) + "_" + str(numpy.float64(time.time()))

options = webdriver.ChromeOptions()
# options.add_argument('headless')
options.add_argument('--log-net-log=' + netlog_name)

caps = DesiredCapabilities.CHROME
caps['loggingPrefs'] = {'performance': 'ALL'}
caps['pageLoadStrategy'] = 'normal'

#print ("webdriver  ....")
browser = webdriver.Chrome(chrome_options=options, desired_capabilities=caps)
maxTimeWait = duration if duration >0 else 30
#print ("webdriver 2 ....")
browser.implicitly_wait(5)
#print ("webdriver 3 ....")
browser.set_page_load_timeout(maxTimeWait)

#print ("get ip ....")
ip = commands.getoutput("echo $(ifconfig ens4) | cut -d ' ' -f7 | cut -d ':' -f2")
#print ("ip:",ip)


try:
    print ("Loading ....")
    # pdb.set_trace()
    initial_time = numpy.float64(time.time())
    #driver.delete_all_cookies()
    # .decode('ascii').encode('ascii', 'ignore')
    browser.get(link)
    print("Visited page: " + browser.title.encode('ascii', 'ignore') + " (" + link + ").")
    if duration >0:
	# Permite esperar la recepcion/reproduccion del video durante unos segundos 
    	time.sleep(duration)
    print (" Finalizada visita")
    # Pause
    '''
    browser.execute_script(
            'document.getElementsByTagName("video")[0].paused ?'
            'document.getElementsByTagName("video")[0].play() :'
            'document.getElementsByTagName("video")[0].pause();')
    '''
    final_time = numpy.float64(time.time())
    msg_err=""

except TimeoutException:
    msg_err="The page is not responding (" + link + ")."
except Exception as e:
    msg_err="Unexpected Error (" + str(e) + "). in link: "+link

log_performance_dict = browser.get_log('performance')

browser.close()
time.sleep(10)
browser.quit()
time.sleep(30)

#printDOM(log_performance_dict,netlog_name)
#generamos luego desde el fichero netlog_xxx
print_sock_vacios ('socks_vacios.txt',netlog_name)

if msg_err != "":
    print ("ERROR:"+msg_err)
    exit(1)
else:
    exit(0)
