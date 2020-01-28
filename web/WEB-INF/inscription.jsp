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
--%>


<form method="post" action="inscription">
    <fieldset>
        <legend>Inscription</legend>
        <p>Vous pouvez vous inscrire via ce formulaire.</p>

        <label for="email">Adresse email <span class="requis">*</span></label>
        <input type="text" id="email" name="email" value="" size="20" maxlength="60"/>
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
        <input type="text" id="nom" name="nom" value="" size="20" maxlength="20"/>
        <span class="erreur">${requestScope.erreurs['nom']}</span>
        <br/>

        <input type="submit" value="Inscription" class="sansLabel"/>
        <br/>
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
