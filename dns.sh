#!/bin/bash

# Define font colors here                               # To change the font color to your liking
                                                        # change the number the the left of 'm'
C1='\033[0;37m' #color1 == Grey                         # Example: '\033[0;32m' is for green
C2='\033[0;36m' #color2 == Cyan                         #
C3='\033[0;31m' #color3 == Red                          # 30 Black | 31 Red | 32 Green | 33 Yellow
NC='\033[0m'    #nocolor == back to default font color  # 34 Blue | 35 Magenta | 36 Cyan | 37 Grey

dig_info() {
    local DOMAIN="$1"
    local SUBDOMAIN="${DOMAIN%%.*}"
    local NS=""
    local NSIP=""
    local CNAME=""
    local DIGA=""
    local DIGW=""
    local MX=""
    local MXIP=""
    local DIGT=""
    
    NS=$(dig ${DOMAIN} ns +short | tr '\n' ' ')
    if [ -z "${NS}" ]; then
        echo -e  "\n${C3}<----- Domain Results ----->\n\n${C2}**No NS records found for ${DOMAIN}**${NC}"
        return
    fi
    
    NSIP=$(dig ${NS} +short | tr '\n' ' ')
    echo -e  "\n${C3}<----- Domain Results ----->\n\n${C1}NS records for ${DOMAIN}:${NC}\n${NS}\n${NSIP}${NC}"
    
    CNAME=$(dig ${DOMAIN} cname +short | tr '\n' ' ')
    if [ "${CNAME}" ]; then
        echo -e  "\n${C1}CNAME records for ${DOMAIN}:\n${NC}${CNAME}${NC}"
    else
        DIGA=$(dig ${DOMAIN} a +short | tr '\n' ' ')
        if [ "${DIGA}" ]; then
            echo -e  "\n${C1}A records for ${DOMAIN}:${NC}\n${DIGA}${NC}"
        fi
    fi
    
    DIGW=$(dig www.${DOMAIN} a +short | tr '\n' ' ')
    if [ "${DIGW}" ]; then
        echo -e  "${C1}\nA records for www.${DOMAIN}:${NC}\n${DIGW}${NC}"
    fi
    
    MX=$(dig ${DOMAIN} mx +short | cut -d' ' -f2)
    if [ "${MX}" ]; then
        MXIP=$(dig ${MX} +short | tr '\n' ' ')
        echo -e  "${C1}\nMX records for ${DOMAIN}:${NC}\n${MX}\n${MXIP}${NC}"
    fi
    
    DIGT=$(dig ${DOMAIN} txt +short)
    if [ "${DIGT}" ]; then
        echo -e  "${C1}\nTXT records for ${DOMAIN}:${NC}\n\n${DIGT}"
    fi
}

who_case (){
    TLD=$(echo -e "${DOMAIN}" | cut -f2-4 -d.)
    case "${TLD}" in
        com|net|COM|NET)
            com_net_who
            ;;
        org|info|me|co|biz|ORG|INFO|ME|CO|BIZ)
            org_info_me_co_biz_who
            ;;
        ca|CA)
            ca_who
            ;;
        *)
            gen_who
            ;;
    esac
    echo -e  "\n${C3}<----- End of Results ----->${NC}\n"
}

com_net_who (){
    if [ "${WHO}" ]; then
        echo -e  "\n${C1}WHOIS info for ${DOMAIN}:${NC}\n"
        echo -e "${WHO}" > ~/.whois.tmp
        echo -e  "${C2}Registrar:${NC}"
        egrep -w 'Registrar:|Reseller:' ~/.whois.tmp | sed 's/^.*Registrar: //' | uniq -i
        echo -e  "\n${C2}Status:${NC}"
        egrep -w 'Domain Status' ~/.whois.tmp | awk '{print $3}'
        echo -e  "\n${C2}Important Dates:${NC}"
        egrep -w 'Date:' ~/.whois.tmp | awk '{print $1, $2, $3}'
        echo -e  "\n${C2}Contact Details:${NC}"
        egrep -w 'Registrant Name:|Registrant Email:' ~/.whois.tmp
        echo -e
        egrep -w 'Admin Name:|Admin Email:' ~/.whois.tmp
        rm ~/.whois.tmp
    else
        echo -e  "\n${C1}WHOIS info for ${DOMAIN}:${NC}\n"
        whois "domain $DOMAIN" | egrep "Registrar:|Status:|Date:" > ~/.whois.tmp
        echo -e  "${C2}Registrar:${NC}"
        egrep -w 'Registrar:|Reseller:' ~/.whois.tmp | sed 's/^.*Registrar: //' | uniq -i
        echo -e  "\n${C2}Status:${NC}"
        egrep -w 'Status:' ~/.whois.tmp | awk '{print $3}'
        echo -e  "\n${C2}Important Dates:${NC}"
        egrep -w 'Date:' ~/.whois.tmp | awk '{print $1, $2, $3}'
        echo -e  "\n${C2}Contact Details:${NC}\nNot available via command line\n"
        rm ~/.whois.tmp
    fi
}

org_info_me_co_biz_who (){
    if [ "${WHO}" ]; then
        echo -e  "\n${C1}WHOIS info for ${DOMAIN}:${NC}\n"
        echo -e "${WHO}" > ~/.whois.tmp
        echo -e  "${C2}Registrar:${NC}"
        egrep -w 'Sponsoring Registrar' ~/.whois.tmp | sed 's/^.*Sponsoring Registrar://' | awk '{print $1, $2, $3, $4, $5}'
        echo -e  "\n${C2}Domain Status:${NC}"
        egrep -w 'Domain Status' ~/.whois.tmp | sed 's/^.*Domain Status://' | awk '{print $1, $2, $3}'
        echo -e  "\n${C2}Important Dates:${NC}"
        egrep -w 'Date' ~/.whois.tmp
        echo -e  "\n${C2}Contact Details:${NC}"
        egrep -w 'Registrant Name|Registrant Email|Registrant E-mail' ~/.whois.tmp
        echo -e
        egrep -w 'Admin Name|Admin Email|Admin E-mail|Administrative' ~/.whois.tmp
        rm ~/.whois.tmp
    else
        no_term_info
    fi
}

ca_who (){
    if [ "${WHO}" ]; then
        echo -e  "\n${C1}WHOIS info for ${DOMAIN}:${NC}\n"
        echo -e "${WHO}" > ~/.whois.tmp
        echo -e  "${C2}Registrar:${NC}"
        grep -A 1 Registrar ~/.whois.tmp | awk '{print $2, $3, $4, $5}' | egrep -v '^[[:space:]]*$'
        echo -e  "\n${C2}Domain Status:${NC}"
        egrep -w 'status:' ~/.whois.tmp | awk '{print $3}'
        echo -e  "\n${C2}Important Dates:${NC}"
        egrep -w 'date:' ~/.whois.tmp
        echo -e  "\n${C2}Contact Details:${NC}"
        grep -A 9 Registrant ~/.whois.tmp
    else
        no_term_info
    fi
}

gen_who (){
    if [ "${WHO}" ]; then
        echo -e  "\n${C1}WHOIS info for ${DOMAIN}:${NC}\n"
        echo -e "${WHO}" > ~/.whois.tmp
        echo -e  "${C3}**Results may be limited for .${TLD} domains**\n**A WHOIS search should yield more results**\n"
        echo -e  "${C2}Registrar:${NC}"
        egrep -w 'Registrar|provider:|Tag' ~/.whois.tmp | sed 's/^.*Registrar://'
        echo -e  "\n${C2}Domain Status:${NC}"
        egrep -w 'Domain Status|status' ~/.whois.tmp | egrep -v 'Registration'
        echo -e  "\n${C2}Important Dates:${NC}"
        egrep -w 'Date|date|created|expires|changed|on|updated' ~/.whois.tmp
        echo -e  "\n${C2}Contact Details:${NC}"
        egrep -w 'Email|contact|Name|owner|responsible|E-mail' ~/.whois.tmp | egrep -v 'Servers|servers|provider|Server|server'
        rm ~/.whois.tmp
    else
        no_term_info
    fi
}

no_term_info (){
    echo -e  "\n${C1}WHOIS info for ${DOMAIN}:${NC}\n\n${C2}Not available in terminal\nFind info here: http://whois.icann.org${NC}"
}

if [ -n "$1" ]; then
    clear
    DOMAIN=$(echo -e "$1" | cut -d/ -f3 | sed 's/^.*www.//')
    DIG=$(dig $DOMAIN +short)
    NS=$(dig ${DOMAIN} ns +short)
    CNAME=$(dig $DOMAIN cname +short)
    case "$1" in
        *.com|*.net|*.COM|*.NET)
            WHO=$(whois "${DOMAIN}" | egrep -w 'Registrar:|Date:|Email:|Domain Status:|Name:|Reseller:' | egrep -v 'Z$|0700$|0800$')
            dig_info "$DOMAIN"
            if [ "$WHO" ]; then
                who_case "$DOMAIN"
            else
                WHO=$(whois "$DOMAIN" | egrep -w 'Registrar:|Date:|Email:|Domain Status:|Name:|Reseller:' | egrep -v 'Z$|0700$|0800$')
                who_case "$DOMAIN"
            fi
            ;;
        *.org|*.info|*.me|*.ORG|*.INFO|*.ME)
            WHO=$(whois "${DOMAIN}" | egrep -w 'Sponsoring Registrar|Registrant|Admin|Domain Status|Date|Reseller' | egrep -v 'ID')
            dig_info "${DOMAIN}"
            if [ "$WHO" ]; then
                who_case "$DOMAIN"
            else
                WHO=$(whois "$DOMAIN" | egrep -w 'Registrar:|Date:|Email:|Domain Status:|Name:|Reseller:' | egrep -v 'Z$|0700$|0800$')
                who_case "$DOMAIN"
            fi
            ;;
        *.co|*.biz|*.CO|*BIZ)
            WHO=$(whois "${DOMAIN}" | egrep -w "Sponsoring Registrar:|Domain Status:|Registrant Name:|Registrant Organization:|Registrant Email:|Administrative Contact Name:|Administrative Contact Email:|Date:")
            dig_info "${DOMAIN}"
            if [ "$WHO" ]; then
                who_case "$DOMAIN"
            else
                WHO=$(whois "$DOMAIN" | egrep -w 'Registrar:|Date:|Email:|Domain Status:|Name:|Reseller:' | egrep -v 'Z$|0700$|0800$')
                who_case "$DOMAIN"
            fi
            ;;
        *.ca|*.CA)
            WHO=$(whois "${DOMAIN}" | egrep -w 'status:|date:|Registrar:|Registrant:|Name:|Email:|contact:')
            dig_info "${DOMAIN}"
            if [ "$WHO" ]; then
                who_case "$DOMAIN"
            else
                WHO=$(whois "$DOMAIN" | egrep -w 'Registrar:|Date:|Email:|Domain Status:|Name:|Reseller:' | egrep -v 'Z$|0700$|0800$')
                who_case "$DOMAIN"
            fi
            ;;
        *)
            WHO=$(whois "${DOMAIN}" | egrep -w 'Name|Email|E-mail|Registrar|Registrant|contact|Domain Status|status|Date|date|owner|responsible|created|expires|changed|provider|Registered|updated|Tag' | egrep -v 'codes|ID|Domain Name|Billing|Abuse|NOTICE|view|agreement|reflect')
            dig_info "${DOMAIN}"
            if [ "$WHO" ]; then
                who_case "$DOMAIN"
            else
                WHO=$(whois "$DOMAIN" | egrep -w 'Registrar:|Date:|Email:|Domain Status:|Name:|Reseller:' | egrep -v 'Z$|0700$|0800$')
                who_case "$DOMAIN"
            fi
    esac
else
    echo -e  "\nI need a domain.\nUsage: $0 DOMAIN.TLD\n"
fi
