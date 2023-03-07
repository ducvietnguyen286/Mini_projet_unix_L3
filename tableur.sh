#!/bin/bash
verifie_fichier()
{
	if test ! -f $1
	then
		echo "Fichier en entré inexistant, vous devrez entrer la feuille de calcul sur l'entrée standard"
	else
		fichier_in=1
		echo "Fichier existant"
		nom_fichier_in=$1
	fi
}
out_resultat() {
	fichier_out=1
	if [ -f $1 ]
	then
		echo "$1 existe deja"
	else
		touch $1
		echo "On creer le fichier $1"
	fi
	nom_fichier_out=$1
}
scin_sep() {
	if [ $# -eq 1 ] && [ "$1" != "\t" ]
	then
		scin="$1"
	fi
}
slin_sep() {
	if [ $# -eq 1 ]
	then
		echo "UI : '$1'"
		slin="$1"
		slin=$slin
	fi
}
scout_sep() {
	if [ $# -eq 1 ]
	then
		scout="$1"
	fi
}
slout_sep() {
	if [ $# -eq 1 ]
	then
		slout="$1"
	fi
}
verification_option() {
	if [ $# -ne 0 ]
	then
		case $1 in
			"-in")
				verifie_fichier $2
				;;
			"-out")
				out_resultat $2
				;;
			"-scin")
				scin_sep $2
				;;
			"-scout")
				scout_sep $2
				;;
			"-slin")
				slin_sep $2
				;;
			"-slout")
				slout_sep $2
				;;
			*)
				echo "ERREUR : Option de commande invalide !" && exit 0
		esac
		shift
		shift
		verification_option $@
	fi
}

creer_fichier_in() { #Creer le fichier d'entrer à partir de ce que l'user écrit dans le terminal
	> fichier #On crée un fichier
	echo "/!\ Respecter les séparateurs de fichier d'entrée /!\\"
	echo "\nVous allez écrire votre feuille source dans le terminal :(appuyé sur ENTREE et ecrire 'FIN' quand vous avez terminé"
	local ligne=""
	while [ -z "$ligne" ] || [ "$ligne" != "FIN" ]
	do
		if [ -n "$ligne" ]
		then
			echo "$ligne" >> fichier
		fi
		read ligne
	done
	echo
	nom_fichier_in="fichier"
}

creer_fichier_out() { #Creer le fichier de sortie
	> fichier2 #Créer un fichier
	nom_fichier_out="fichier2"
}
valeur_cellule() { #Prend la ligne & la colonne en parametre en retourne ce qu'il y a a Ligne lig & Colonne col
	local lig="$1"
	local col="$2"
	local celulle=""
	#echo -e "Lig $lig Col $col : \c"
	if [ "$slin" = "\n" ]
	then
		#echo "Cas 1a"
		cellule=`cat "$nom_fichier_in" | sed -n "$lig"p`
	elif [ "$slin" = "\t" ]
	then
		#echo "Cas 1c"
		cellule=`cat "$nom_fichier_in" | cut -d$'\t' -f"$lig"`
	else
		#echo "Cas 1b"
		cellule=`cat "$nom_fichier_in" | cut -d"$slin" -f"$lig"`
	fi
	#echo "Ligne cellule : $cellule"
	if [ "$scin" = "\n" ]
	then
		#echo "Cas 2a"
		cellule=` "$cellule" | sed -n "$lig"p`
	elif [ "$scin" = "\t" ]
	then
		#echo "Cas 2c"
		#echo "$cellule" | cut -d\t -f"$col"
		cellule=`echo "$cellule" | cut -d$'\t' -f"$col"`
	else
		#echo "Cas 2b"
		cellule=`echo $cellule | cut -d"$scin" -f"$col"`
	fi
	echo "$cellule"


}
recupere_cellule() { #Recupere la cellule [lici]
	local lig=`echo "$1" | cut -d"l" -f2 | cut -d"c" -f1`
	local col=`echo "$1" | cut -d"]" -f1 | cut -d"c" -f2`
	local res=`valeur_cellule "$lig" "$col"`
	echo "$res"
}
enleveParentheses()
{
	local p=""
	local val=$1
	local length=${#val}
	length=`expr $length - 1`
	for i in `seq 2 $length`
	do
		p="$p"`echo -e "${val}" | cut -c $i`
	done

	echo -e "$p" 
}
uneVal() {
	local nbParentheses=0
	local finVal2=0
	local val2=""
	local ind=0
	local val=$1
	local length=${#val}

	while [ "$finVal2" -eq 0 ]
	do
		if [ "$ind" -lt $length ]
		then
			carac=${val:$ind:1}
			if [ "$carac" \= "(" ]
			then
				nbParentheses=`expr "$nbParentheses" + 1`
				val2="$val2""$carac"
	 		elif [ "$carac" \= ")" ]
	 		then
	 			nbParentheses=`expr "$nbParentheses" - 1`
				val2="$val2""$carac"
			elif [ "$carac" = "," ]
				then
				if [ "$nbParentheses" -eq 0 ]
				then
					finVal2=1
				else
					val2="$val2""$carac"
				fi
			else
				val2="$val2""$carac"
			fi
		fi
		ind=`expr "$ind" + 1`
		if [ "$ind" -eq "$length" ]
		then
			finVal2=1
		fi
	done
	echo -e "$val2"
}
doubleVal() {
	local nbParentheses=0
	local finVal1=0
	local finVal2=0
	local val1=""
	local val2=""
	local ind=0
	local val=$1
	local length=${#val}


	################ Recuperation de val1 #################

	while [ "$finVal1" -eq 0 ]
	do

		if [ "$ind" -lt $length ]
		then
			carac=${val:$ind:1}
			if [ "$carac" \= "(" ]
			then
				nbParentheses=`expr "$nbParentheses" + 1`
				val1="$val1""$carac"
	 		elif [ "$carac" \= ")" ]
	 		then
	 			nbParentheses=`expr "$nbParentheses" - 1`
				val1="$val1""$carac"
			elif [ "$carac" = "," ]
				then
				if [ "$nbParentheses" -eq 0 ]
				then
					finVal1=1
				else
					val1="$val1""$carac"
				fi
			else
				val1="$val1""$carac"
			fi
		fi
		ind=`expr "$ind" + 1`
	done

	# # ################ Récuperation de val2 #################

	while [ "$finVal2" -eq 0 ]
	do
		if [ "$ind" -lt $length ]
		then
			carac=${val:$ind:1}
			if [ "$carac" \= "(" ]
			then
				nbParentheses=`expr "$nbParentheses" + 1`
				val2="$val2""$carac"
	 		elif [ "$carac" \= ")" ]
	 		then
	 			nbParentheses=`expr "$nbParentheses" - 1`
				val2="$val2""$carac"
			elif [ "$carac" = "," ]
				then
				if [ "$nbParentheses" -eq 0 ]
				then
					finVal2=1
				else
					val2="$val2""$carac"
				fi
			else
				val2="$val2""$carac"
			fi
		fi
		ind=`expr "$ind" + 1`
		if [ "$ind" -eq "$length" ]
		then
			finVal2=1
		fi
	done
	echo -e "$val1 $val2"
}
addition() {
	local val=`echo "$1" | cut -d"+" -f2-`
	val=`enleveParentheses $val`

	#On recupère val1 et val2
	local lesVals=`doubleVal $val`
	local val1=`echo "$lesVals" | cut -d" " -f1`
	local val2=`echo "$lesVals" | cut -d" " -f2`
	val1=`lance_calcul "$val1"`
	val2=`lance_calcul "$val2"`
	local res=`echo -e "scale=2;$val1 + $val2" | bc -l`
	echo -e "$res"
}
soustraction() {
	local val=`echo "$1" | cut -d"-" -f2-`
	val=`enleveParentheses $val`

	#On recupère val1 et val2
	local lesVals=`doubleVal $val`
	local val1=`echo "$lesVals" | cut -d" " -f1`
	local val2=`echo "$lesVals" | cut -d" " -f2`
	val1=`lance_calcul "$val1"`
	val2=`lance_calcul "$val2"`
	local res=`echo -e "scale=2;$val1 - $val2" | bc -l`
	echo -e "$res"
}
multiplication() {
	local val=`echo "$1" | cut -d"*" -f2-`
	val=`enleveParentheses $val`

	#On recupère val1 et val2
	local lesVals=`doubleVal $val`
	local val1=`echo "$lesVals" | cut -d" " -f1`
	local val2=`echo "$lesVals" | cut -d" " -f2`
	val1=`lance_calcul "$val1"`
	val2=`lance_calcul "$val2"`
	local res=`echo -e "scale=2;$val1 * $val2" | bc -l`
	echo -e "$res"
}
division() {
	local val=`echo "$1" | cut -d"/" -f2-`
	val=`enleveParentheses $val`

	#On recupère val1 et val2
	local lesVals=`doubleVal $val`
	local val1=`echo "$lesVals" | cut -d" " -f1`
	local val2=`echo "$lesVals" | cut -d" " -f2`
	val1=`lance_calcul "$val1"`
	val2=`lance_calcul "$val2"`
	local res=`echo -e "scale=2;$val1 / $val2" | bc -l`
	echo -e "$res"
}
puissance() {
	local val=`echo "$1" | cut -d"^" -f2-`
	val=`enleveParentheses $val`

	#On recupère val1 et val2
	local lesVals=`doubleVal $val`
	local val1=`echo "$lesVals" | cut -d" " -f1`
	local val2=`echo "$lesVals" | cut -d" " -f2`
	val1=`lance_calcul "$val1"`
	val2=`lance_calcul "$val2"`
	local res=`echo -e "scale=2;$val1 ^ $val2" | bc -l`
	echo -e "$res"
}
logarithme() {
	local val=`echo "$1" | cut -d"n" -f2-`
	val=`enleveParentheses $val`

	val=`uneVal "$val"`
	local res=`echo -e "scale=2;l($val)" | bc -l`
	echo -e "$res"
}
expo() {
	local val=`echo "$1" | cut -d"e" -f2-`
	val=`enleveParentheses $val`

	val=`uneVal "$val"`
	local res=`echo "scale=2;e($val)" | bc -l`
	echo -e "$res"
}
sqrt() {
	local val=`echo "$1" | cut -d"t" -f2-`
	val=`enleveParentheses $val`

	val=`uneVal "$val"`
	local res=`echo "scale=2;sqrt($val)" | bc -l`
	echo -e "$res"
}
somme() {
	local val=`echo "$1" | cut -d"e" -f2-`
	val=`enleveParentheses $val`

	
	local lesVals=`doubleVal $val`
	local val1=`echo "$lesVals" | cut -d" " -f1`
	local val2=`echo "$lesVals" | cut -d" " -f2`
	local i=`echo "$val1" | cut -d"l" -f2 | cut -d"c" -f1` #ligne de depart
	local j=`echo "$val1" | cut -d"c" -f2 | cut -d"]" -f1` #colonne de depart
	local i_max=`echo "$val2" | cut -d"l" -f2 | cut -d"c" -f1` #ligne de fin
	local j_max=`echo "$val2" | cut -d"c" -f2 | cut -d"]" -f1` #colonne de fin

	local res="first"
	local val=""

	while [ "$i" -le "$i_max" ]
	do
		if [ "$res" = "first" ]
		then
			res=0
		else
			j=1
		fi
		while [ "$j" -le "$nb_col" ]
		do
			val=`valeur_cellule $i $j`
			val=`calcul_cellule $val`
			res=`echo -e "scale=2;$res + $val" | bc -l`
			if [ "$i" -eq "$i_max" ] && [ "$j" -eq "$j_max" ]
			then
				j=`expr "$nb_col" + 1`
			else 
				j=`expr "$j" + 1`
			fi
		done
		i=`expr "$i" + 1`
	done
	echo "$res"
}
lance_calcul() {
	local cel="$1" #On récupère la valeur de la cellule
	expr $cel + 0 1>/dev/null 2>&1
	statut=$?
	if test $statut -lt 2 #Si c'est un réel
	then
		res="$cel"
	else
		local fonc=`echo "$cel" | cut -d"(" -f1` #Recuperation de la fonction de calcul a lancer
		local carac="${fonc:0:1}" #On récupère le premier carac de la fonction pour savoir si ce n'est pas une cellule ex : [l1c1]
		local res=""

		if [ "$carac" = "[" ]
		then
			res=`recupere_cellule $cel`
			res=`calcul_cellule "$res"`
		else
			case $fonc in
			"+") res=`addition "$cel"`;;
			"-") res=`soustraction "$cel"`;;
			"*") res=`multiplication "$cel"`;;
			"/") res=`division "$cel"`;;
			"^") res=`puissance "$cel"`;;
			"ln") res=`logarithme "$cel"`;;
			"e") res=`expo "$cel"`;;
			"sqrt") res=`sqrt "$cel"`;;
			"somme") res=`somme "$cel"`;;
			*) res="ERREUR"
			esac
		fi
	fi
	echo -e "$res"
}
calcul_cellule() { #Verifie si il y a un calcul a effectuer dans la cellule avec le '='
	local res=""
	local cel=""
	local carac="${1:0:1}" #On récupère le premier caractère pour voir si on doit effectuer un calcul
	if [ "$carac" = "=" ]
	then
		cel=`echo "$1" | cut -d"=" -f2` #On retire le '='
		res=`lance_calcul "$cel"`
	else
		res="$1"
	fi
	echo "$res"
}
analyseTableur() { #fonction qui lance l'analyse sur chacun des cellules
	local res=""
	local j=1
	local i=1
	local cel=""
	nb_col=""
	if [ "$slin" = "\n" ] #Cas Spécial
	then
		nb_col=`cat "$nom_fichier_in" | sed -n 1p | sed 's/[^'$scin']//g' | wc -c`
	elif [ "$slin" = "\t" ] #Cas spécial
	then
		nb_col=`cat "$nom_fichier_in" | cut -d$'\t' -f1 | sed 's/[^'$scin']//g' | wc -c`
	else
		nb_col=`cat "$nom_fichier_in" | cut -d"$slin" -f1 | sed 's/[^'$scin']//g' | wc -c`
	fi
	nb_lig=`cat "$nom_fichier_in" | sed 's/[^'$slin']//g' | wc -c`


	echo "Nb col : "$nb_col""
	echo "Nb lig : "$nb_lig""
	while [ "$i" -le "$nb_lig" ]
	do
		j=1
		while [ "$j" -le "$nb_col" ]
		do
			cel=`valeur_cellule $i $j`
			echo "Val cel :$cel"
			res=`calcul_cellule "$cel"`
			echo -e "Calcul_cellule --> $res\n"

			#On ecrit le resultat dans le fichier de sortie
			echo -e "$res\c" >> "$nom_fichier_out"
			if [ "$j" -ne "$nb_col" ] #Si on n'est pas a la dernière colonne 
			then
				echo -e "$scout\c" >> "$nom_fichier_out"
			fi
			j=`expr "$j" + 1`
		done
		if [ "$i" -ne "$nb_lig" ] #Si on n'est pas a la dernière ligne 
		then
			echo -e "$slout\c" >> "$nom_fichier_out"
		fi
		i=`expr "$i" + 1`
	done
}
init_out() { #Initialise le fichier de sortie
	local i=0
	local j=1
	while [ "$i" -ne "$nb_lig" ]
	do
		j=1
		while [ "$j" -ne "$nb_col" ]
		do
			echo -e "$scout\c" >> "$nom_fichier_out"
			j=`expr "$j" + 1`
		done
		i=`expr "$i" + 1`
		if [ "$i" -ne "$nb_lig" ]
		then
			echo -e "$slout\c" >> "$nom_fichier_out"
		fi
	done
}
ajoute_cel_out() { #Prend la valeur de la cellule en sortie, la ligne et la colonne
	local cel=$1
	local lig=$2
	local col=$3
}

principale() {
	if [ "$fichier_in" -eq 0 ] #Si l'on n'a pas de fichier en entrée
	then
		creer_fichier_in
	fi
	if [ "$fichier_out" -eq 0 ] #Si l'on n'a pas préciser de fichier de sortie
	then
		creer_fichier_out #On en crée un qu'on affichera par la suite sur le terminal
	fi
	echo -e "\c" > "$nom_fichier_out" #Initialisation du fichier de sortie a vide
	echo -e "Nom In : "$nom_fichier_in"\nNom Out : "$nom_fichier_out""
	analyseTableur
	#AFFICHER ICI LE TABLEUR SUR LE TERMINAL SI FICHIER_OUT == 0 avec un cat
	echo "FIN PRINCIPALE"
}

fichier_in=0
nom_fichier_in=""
fichier_out=0
nom_fichier_out=""
scin="\t"
slin="\n"
scout=""
slout=""
nb_col=""
nb_lig=""
verification_option $@
if [ -z "$scout" ] #On teste si scout est définie
then
	scout="$scin"
fi
if [ -z "$slout" ] #On teste si slout est définie
then
	slout="$slin"
fi
echo -e "####### INFOS ENTREE ######\n"
echo -e "Fichier IN : "$fichier_in""
test "$fichier_in" -eq 1 && echo "Nom fichier in : "$nom_fichier_in""
echo -e "Fichier OUT : "$fichier_out""
test "$fichier_out" -eq 1 && echo "Nom fichier out : "$nom_fichier_out""
echo -e "Le separateur de colonne IN est : '$scin'"
echo -e "Le sepateur de ligne IN est : '$slin'"
echo -e "Le separateur de colonne OUT est : '$scout'"
echo -e "Le separateur de ligne OUT est  : '$slout'"
echo -e "########################\n"
principale
