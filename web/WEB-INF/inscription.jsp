<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%--
  Created by IntelliJ IDEA.
  User: jorge.carrillo
  Date: 1/27/2020
  Time: 8:26 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8"/>
    <title>Inscription</title>
    <link type="text/css" rel="stylesheet" href="form.css"/>
</head>
<body>
<%--
------------------------------------------------------------------------------------------------------------------------
                                      1. Afficher les messages d'erreurs
------------------------------------------------------------------------------------------------------------------------
 L'attribut erreurs que nous recevons de la servlet ne contient des messages concernant les différents champs de notre
 formulaire que si des erreurs ont été rencontrées lors de la validation de leur contenu, c'est-à-dire uniquement si des
 exceptions ont été envoyées. Ainsi, il nous suffit d'afficher les entrées de la Map correspondant à chacun des champs
 email, motdepasse, confirmation et nom :

 Vous retrouvez aux lignes 17, 22, 27 et 32 l'utilisation des crochets pour accéder aux entrées de la Map, comme nous
 l'avions déjà fait lors de notre apprentissage de la JSTL. De cette manière, si aucun message ne correspond dans la
 Map à un champ du formulaire donné, c'est qu'il n'y a pas eu d'erreur lors de sa validation côté serveur. Dans ce cas,
 la balise <span> sera vide et aucun message ne sera affiché à l'utilisateur. Comme vous pouvez le voir, j'en ai profité
 pour ajouter un style à notre feuille form.css, afin de mettre en avant les erreurs :

 Vous pouvez maintenant faire le test : remplissez votre formulaire avec des données erronées (une adresse mail invalide,
 un nom d'utilisateur trop court ou des mots de passe différents, par exemple) et contemplez le résultat ! À la figure
 suivante, le rendu attendu lorsque vous entrez un nom d'utilisateur trop court.

------------------------------------------------------------------------------------------------------------------------
                                  2. Réafficher les données saisies par l'utilisateur
------------------------------------------------------------------------------------------------------------------------

 Comme vous le constatez sur cette dernière image, les données saisies par l'utilisateur avant validation du
 formulaire disparaissent des champs après validation. En ce qui concerne les champs mot de passe et confirmation,
 c'est très bien ainsi : après une erreur de validation, il est courant de demander à l'utilisateur de saisir à
 nouveau cette information sensible. Dans le cas du nom et de l'adresse mail par contre, ce n'est vraiment pas
 ergonomique et nous allons tâcher de les faire réapparaître. Pour cette étape, nous pourrions être tentés de
 simplement réafficher directement ce qu'a saisi l'utilisateur dans chacun des champs "value" des <input> du
 formulaire. En effet, nous savons que ces données sont directement accessibles via l'objet implicite param, qui
 donne accès aux paramètres de la requête HTTP. Le problème, et c'est un problème de taille, c'est qu'en procédant
 ainsi nous nous exposons aux failles XSS. Souvenez-vous : je vous en ai déjà parlé lorsque nous avons découvert
 la balise <c:out> de la JSTL !

 Quel est le problème exactement ?

Bien... puisque vous semblez amnésiques et sceptiques, faisons comme si de rien n'était, et réaffichons le contenu
des paramètres de la requête HTTP (c'est-à-dire le contenu saisi par l'utilisateur dans les champs <input> du formulaire)
en y accédant directement via l'objet implicite param, aux lignes 16 et 31 :

Faites alors à nouveau le test en remplissant et validant votre formulaire. Dorénavant, les données que vous avez
entrées sont bien présentes dans les champs du formulaire après validation, ainsi que vous pouvez le constater à la
figure suivante.

                   <label for="email">Adresse email <span class="requis">*</span></label>
                   <input type="text" id="email" name="email" value="${param.email}" size="20" maxlength="60"/>
                   <span class="erreur">${requestScope.erreurs['email']}</span>
                   <br/>

En apparence ça tient la route, mais je vous ai lourdement avertis : en procédant ainsi, votre code est vulnérable
aux failles XSS. Vous voulez un exemple ? Remplissez le champ nom d'utilisateur par le contenu suivant : ">Bip bip ! .
Validez ensuite votre formulaire, et contemplez alors ce triste et désagréable résultat (voir la figure suivante).

------------------------------------------------------------------------------------------------------------------------
                                                 Que s'est-il passé ?
------------------------------------------------------------------------------------------------------------------------

Une faille XSS, pardi ! Eh oui, côté serveur, le contenu que vous avez saisi dans le champ du formulaire a été copié
tel quel dans le code généré par notre JSP. Il a ensuite été interprété par le navigateur côté client, qui a alors
naturellement considéré que le guillemet " et le chevron > contenus en début de saisie correspondaient à la fermeture
de la balise <input> ! Si vous êtes encore dans le flou, voyez plutôt le code HTML produit sur la ligne posant
problème :

             <input type="text" id="nom" name="nom" value="">Bip bip !" size="20" maxlength="20" />

Vous devez maintenant comprendre le problème : le contenu de notre champ a été copié puis collé tel quel dans la source
de notre fichier HTML final, lors de l'interprétation par le serveur de l'expression EL que nous avons mise en place
(c'est-à-dire ${param.nom}). Et logiquement, puisque le navigateur ferme la balise <input> prématurément, notre joli
formulaire s'en retrouve défiguré. Certes, ici ce n'est pas bien grave, je n'ai fait que casser l'affichage de la page.
Mais vous devez savoir qu'en utilisant ce type de failles, il est possible de causer bien plus de dommages, notamment
en injectant du code Javascript dans la page à l'insu du client.

Je vous le répète : la règle d'or, c'est de ne jamais faire confiance à l'utilisateur.

Pour pallier ce problème, il suffit d'utiliser la balise <c:out> de la JSTL Core pour procéder à l'affichage des données.
Voici ce que donne alors le code modifié de notre JSP, observez bien les lignes 17 et 32 :

    <input type="text" id="email" name="email" value="<c:out value="${param.email}"/>" size="20" maxlength="60"/>

La balise <c:out> se chargeant par défaut d'échapper les caractères spéciaux, le problème est réglé. Notez l'ajout de
la directive taglib en haut de page, pour que la JSP puisse utiliser les balises de la JSTL Core. Faites à nouveau le
test avec le nom d'utilisateur précédent, et vous obtiendrez bien cette fois le résultat affiché à la figure suivante.

Dorénavant, l'affichage n'est plus cassé, et si nous regardons le code HTML généré, nous observons bien la
transformation du " et du > en leurs codes HTML respectifs par la balise <c:out> :

             <input type="text" id="nom" name="nom" value="&#034;&gt;Bip bip !" size="20" maxlength="20" />

Ainsi, le navigateur de l'utilisateur reconnaît que les caractères " et > font bien partie du contenu du champ, et
qu'ils ne doivent pas être interprétés en tant qu'éléments de fermeture de la balise <input> !

À l'avenir, n'oubliez jamais ceci : protégez toujours les données que vous affichez à l'utilisateur !

------------------------------------------------------------------------------------------------------------------------
                                  3. Afficher le résultat final de l'inscription
------------------------------------------------------------------------------------------------------------------------

Il ne nous reste maintenant qu'à confirmer le statut de l'inscription. Pour ce faire, il suffit d'afficher l'entrée
resultat de la Map dans laquelle nous avons initialisé le message, à la ligne 149 dans le code suivant :

Vous remarquez ici l'utilisation d'un test ternaire sur notre Map erreurs au sein de la première expression EL mise en
place, afin de déterminer la classe CSS à appliquer au paragraphe. Si la Map erreurs est vide, alors cela signifie
qu'aucune erreur n'a eu lieu et on utilise le style nommé succes, sinon on utilise le style erreur. En effet, j'en ai
profité pour ajouter un dernier style à notre feuille form.css, pour mettre en avant le succès de l'inscription :

       * Les pages placées sous /WEB-INF ne sont par défaut pas accessibles au public par une URL.

       * La méthode d'envoi des données d'un formulaire se définit dans le code HTML via <form method="...">.

       * Les données envoyées via un formulaire sont accessibles côté serveur via des appels à request.getParameter( "nom_du_champ" ).

       * La validation des données, lorsque nécessaire, peut se gérer simplement avec les exceptions et des interceptions
         via des blocs try / catch.

       * Le renvoi de messages à l'utilisateur peut se faire via une simple Map placée en tant qu'attribut de requête.

       * L'affichage de ces messages côté JSP se fait alors via de simples et courtes expressions EL.

       * Il ne faut jamais afficher du contenu issu d'un utilisateur sans le sécuriser, afin d'éliminer le risque de
         failles XSS.

       * Placer la validation et les traitements sur les données dans la servlet n'est pas une bonne solution, il faut
         trouver mieux.

--%>


<form method="post" action="inscription">
    <fieldset>
        <legend>Inscription</legend>
        <p>Vous pouvez vous inscrire via ce formulaire.</p>

        <label for="email">Adresse email <span class="requis">*</span></label>
        <input type="text" id="email" name="email" value="<c:out value="${param.email}"/>" size="20" maxlength="60"/>
        <span class="erreur">${requestScope.erreurs['email']}</span>
        <br/>

        <label for="motdepasse">Mot de passe <span class="requis">*</span></label>
        <input type="password" id="motdepasse" name="motdepasse" value="" size="20" maxlength="20"/>
        <span class="erreur">${requestScope.erreurs['motdepasse']}</span>
        <br/>

        <label for="confirmation">Confirmation du mot de passe <span class="requis">*</span></label>
        <input type="password" id="confirmation" name="confirmation" value="" size="20" maxlength="20"/>
        <span class="erreur">${requestScope.erreurs['confirmation']}</span>
        <br/>

        <label for="nom">Nom d'utilisateur</label>
        <input type="text" id="nom" name="nom" value="<c:out value="${param.nom}"/>" size="20" maxlength="20"/>
        <span class="erreur">${requestScope.erreurs['nom']}</span>
        <br/>

        <input type="submit" value="Inscription" class="sansLabel"/>
        <br/>

        <p class="${empty requestScope.erreurs ? 'succes' : 'erreur'}">${requestScope.resultat}</p>

    </fieldset>
</form>

<%--
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                         Affichage: côté JSP
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Ce qu'il nous reste maintenant à réaliser, c'est l'affichage de nos différents messages au sein de la page JSP, après
que l'utilisateur a saisi et envoyé ses données. Voici ce que je vous propose :

1) en cas d'erreur, affichage du message d'erreur à côté de chacun des champs concernés ;

2) ré-affichage dans les champs <input> des données auparavant saisies par l'utilisateur ;

3) affichage du résultat de l'inscription en bas du formulaire.

--%>

</body>
</html>
