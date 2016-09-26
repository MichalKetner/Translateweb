#!/usr/bin/env bash


function download_articles() {
    
    # 1. curl downloads rss feed of given namespace
    # 2. grep raw links to articles
    # 3. first sed replace start of tag and replace usual link to the export link
    # 4. second sed replace end of tag
    # 5. wget download every argument (article)
    cd $namespace
    wget $(curl "https://www.pirati.cz/feed.php?mode=list&linkto=current&ns=${namespace}" | grep item\ rdf:about | sed 's@    <item rdf:about="https://www.pirati.cz/@https://www.pirati.cz/_export/raw/@' | sed 's@">$@@')
    cd -
}

function rename() {
	cd $namespace 
	ls | while read file; do
		mv $file "${file}.txt"
		
	done
	cd -
		}
function convert_articles() {
    	cd $namespace
	convert_bin="../DokuWiki-to-Markdown-Converter/convert.php"; #skript byl ve stejne slozce jako složka Doku.....
	ls | while read file; do
		sed  -i 's/~~NOTOC~~//g' "$file";
		sed  -i 's/~~READMORE~~//g'    "$file";
		sed  -i 's/===== BOX:related =====//g'    "$file";
		sed  -i 's/{{\s*\([^?|}]\+\?\)\(?[^|}]\+\?\)\?\s*\(|\(.\+\?\)\)\?}}/![\4](\1)/g' "$file";
		php "${convert_bin}" "$file";
	done
	rm -f *.txt
        cd -
     
}


echo -e "\033[0;31m Zadejte adresu jmeného prostoru. \n\033[0;32m (Například regiony:praha:tiskove-zpravy) : \e[m "; 
read namespace ;
mkdir -p "${namespace}/";
rm -rf "${namespace}/*";
download_articles;
rename;
convert_articles;
