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
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                         Formulaires : le b.a.-ba
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Dans cette partie, nous allons littéralement faire table rase. Laissons tomber nos précédents exemples, et attaquons
l'étude des formulaires par quelque chose de plus concret : un formulaire d'inscription. Création, mise en place,
récupération des données, affichage et vérifications nous attendent !

Bien entendu, nous n'allons pas pouvoir réaliser un vrai système d'inscription de A à Z : il nous manque encore pour
cela la gestion des données, que nous n'allons découvrir que dans la prochaine partie de ce cours. Toutefois, nous
pouvons d'ores et déjà réaliser proprement tout ce qui concerne les aspects vue, contrôle et traitement d'un tel système.
Allons-y !

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                            Mise en place
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Je vous propose de mettre en place une base sérieuse qui nous servira d'exemple tout au long de cette partie du cours,
ainsi que dans la partie suivante. Plutôt que de travailler une énième fois sur un embryon de page sans intérêt, je
vais tenter ici de vous placer dans un contexte plus proche du monde professionnel : nous allons travailler de manière
propre et organisée, et à la fin de ce cours nous aurons produit un exemple utilisable dans une application réelle.

Pour commencer, je vous demande de créer un nouveau projet dynamique sous Eclipse. Laissez tomber le bac à sable que
nous avions nommé test, et repartez de zéro : cela aura le double avantage de vous permettre de construire quelque
chose de propre, et de vous faire pratiquer l'étape de mise en place d'un projet (création, build-path, bibliothèques, etc.).
Je vous propose de nommer ce nouveau projet pro.

N'oubliez pas les changements à effectuer sur le build-path et le serveur de déploiement, et pensez à ajouter le .jar
de la JSTL à notre projet, ainsi que de créer deux packages vides qui accueilleront par la suite nos servlets et beans.

Revenons maintenant à notre base. En apparence, elle consistera en une simple page web contenant un formulaire destiné
à l'inscription du visiteur sur le site. Ce formulaire proposera :

      * un champ texte recueillant l'adresse mail de l'utilisateur ;

      * un champ texte recueillant son mot de passe ;

      * un champ texte recueillant la confirmation de son mot de passe ;

      * un champ texte recueillant son nom d'utilisateur (optionnel).

Voici à la figure suivante un aperçu du design que je vous propose de mettre en place.

Si vous avez été assidus lors de vos premiers pas, vous devez vous souvenir que, dorénavant, nous placerons toujours
nos pages JSP sous le répertoire /WEB-INF de l'application, et qu'à chaque JSP créée nous associerons une servlet.
Je vous ai ainsi préparé une page JSP chargée de l'affichage du formulaire d'inscription, une feuille CSS pour sa mise
en forme et une servlet pour l'accompagner.

Contrairement à la page JSP, la feuille de style ne doit pas être placée sous le répertoire /WEB-INF ! Eh oui, vous
devez vous souvenir que ce répertoire a la particularité de rendre invisible ce qu'il contient pour l'extérieur :

dans le cas d'une page JSP c'est pratique, cela rend les pages inaccessibles directement depuis leur URL et nous permet
de forcer le passage par une servlet ;

dans le cas de notre feuille CSS par contre, c'est une autre histoire ! Car ce que vous ne savez peut-être pas encore,
c'est qu'en réalité lorsque vous accédez à une page web sur laquelle est attachée une feuille de style, votre navigateur
va, dans les coulisses, envoyer une requête GET au serveur pour récupérer silencieusement cette feuille, en se basant
sur l'URL précisée dans la balise <link href="..." />. Et donc fatalement, si vous placez le fichier sous /WEB-INF,
la requête va échouer, puisque le fichier sera caché du public et ne sera pas accessible par une URL.

------------------------------------------------------------------------------------------------------------------------

De toute manière, dans la très grande majorité des cas, le contenu d'une feuille CSS est fixe ; il ne dépend pas de
codes dynamiques et ne nécessite pas de prétraitements depuis une servlet comme nous le faisons jusqu'à présent pour
nos pages JSP. Nous pouvons donc rendre les fichiers CSS accessibles directement aux navigateurs en les plaçant dans
un répertoire public de l'application.

En l'occurrence, ici j'ai placé cette feuille directement à la racine de notre application, désignée par le répertoire
WebContent dans Eclipse.

Retenez donc bien que tous les éléments fixes utilisés par vos pages JSP, comme les feuilles de style CSS, les feuilles
de scripts Javascript ou encore les images, doivent être placés dans un répertoire public, et pas sous /WEB-INF.

Avant de mettre en place la servlet, penchons-nous un instant sur les deux attributs de la balise <form>.

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                 La méthode
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Il est possible d'envoyer les données d'un formulaire par deux méthodes différentes :

get : les données transiteront par l'URL via des paramètres dans une requête HTTP GET. Je vous l'ai déjà expliqué,
en raison des limitations de la taille d'une URL, cette méthode est peu utilisée pour l'envoi de données.

post : les données ne transiteront pas par l'URL mais dans le corps d'une requête HTTP POST, l'utilisateur ne les
verra donc pas dans la barre d'adresses de son navigateur.

Malgré leur invisibilité apparente, les données envoyées via la méthode POST restent aisément accessibles, et ne sont
donc pas plus sécurisées qu'avec la méthode GET : nous devrons donc toujours vérifier la présence et la validité des
paramètres avant de les utiliser. La règle d'or à suivre lorsqu'on développe une application web, c'est de ne jamais
faire confiance à l'utilisateur.

Voilà pourquoi nous utiliserons la plupart du temps la méthode POST pour envoyer les données de nos formulaires.
En l'occurrence, nous avons bien précisé <form method="post" ... > dans le code de notre formulaire.

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                     La cible
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

L'attribut action de la balise <form> permet de définir la page à laquelle seront envoyées les données du formulaire.
Puisque nous suivons le modèle MVC, vous devez savoir que l'étape suivant l'envoi de données par l'utilisateur est le
contrôle. Autrement dit, direction la servlet ! C'est l'URL permettant de joindre cette servlet, c'est-à-dire l'URL
que vous allez spécifier dans le fichier web.xml, qui doit être précisée dans le champ action du formulaire.

En l'occurrence, nous avons précisé <form ... action="inscription"> dans le code du formulaire, nous devrons donc
associer l'URL /inscription à notre servlet dans le mapping du fichier web.xml.

Lançons-nous maintenant, et créons une servlet qui s'occupera de récupérer les données envoyées et de les valider.

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                     La servlet
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Voici le code de la servlet accompagnant la JSP qui affiche le formulaire :

Pour le moment, elle se contente d'afficher notre page JSP à l'utilisateur lorsqu'elle reçoit une requête GET de sa part.
Bientôt, elle sera également capable de gérer la réception d'une requête POST, lorsque l'utilisateur enverra les données
de son formulaire !

Souvenez-vous : l'adresse contenue dans le champ <url-pattern> est relative au contexte de l'application. Puisque
nous avons nommé le contexte de notre projet pro, pour accéder à la JSP affichant le formulaire d'inscription il faut
appeler l'URL suivante :

http://localhost:8080/pro/inscription


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                                L'envoi des données
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Maintenant que nous avons accès à notre page d'inscription, nous pouvons saisir des données dans le formulaire et les
envoyer au serveur. Remplissez les champs du formulaire avec un nom d'utilisateur, un mot de passe et une adresse mail
de votre choix, puis cliquez sur le bouton d'inscription. Voici à la figure suivante la page que vous obtenez.

Eh oui, nous avons demandé un envoi des données du formulaire par la méthode POST, mais nous n'avons pas surchargé la
méthode doPost() dans notre servlet, nous avons uniquement écrit une méthode doGet(). Par conséquent, notre servlet
n'est pas encore capable de traiter une requête POST !


Nous savons donc ce qu'il nous reste à faire : il faut implémenter la méthode doPost(). Voici le code modifié de
notre servlet :

Maintenant que nous avons ajouté une méthode doPost(), nous pouvons envoyer les données du formulaire, il n'y aura plus
d'erreur HTTP !
Par contre, la méthode doPost() étant vide, nous obtenons bien évidemment une page blanche en retour...

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                      Contrôle : côté servlet
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Maintenant que notre formulaire est accessible à l'utilisateur et que la servlet en charge de son contrôle est en place,
nous pouvons nous attaquer à la vérification des données envoyées par le client.

Que souhaitons-nous vérifier ?

Nous travaillons sur un formulaire d'inscription qui contient quatre champs de type <input>, cela ne va pas être bien
compliqué. Voici ce que je vous propose de vérifier :

      * que le champ obligatoire email n'est pas vide et qu'il contient une adresse mail valide ;

      * que les champs obligatoires mot de passe et confirmation ne sont pas vides, qu'ils contiennent au moins 3
        caractères, et qu'ils sont égaux ;

      * que le champ facultatif nom, s'il est rempli, contient au moins 3 caractères.

Nous allons confier ces tâches à trois méthodes distinctes :

      * une méthode validationEmail(), chargée de valider l'adresse mail saisie ;

      * une méthode validationMotsDePasse(), chargée de valider les mots de passe saisis ;

      * une méthode validationNom(), chargée de valider le nom d'utilisateur saisi.

Voici donc le code modifié de notre servlet, impliquant la méthode doPost(), des nouvelles constantes et les méthodes
de validation créées pour l'occasion, en charge de récupérer le contenu des champs du formulaire et de les faire valider :



--%>

</body>
</html>
