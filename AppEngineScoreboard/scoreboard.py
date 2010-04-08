import cgi

import os
from google.appengine.ext.webapp import template

from google.appengine.api import users
from google.appengine.ext import webapp
from google.appengine.ext.webapp.util import run_wsgi_app
from google.appengine.ext import db

class Points(db.Model):
    #author = db.UserProperty()
    group = db.StringProperty()
    r1pts = db.IntegerProperty()
    r2pts = db.IntegerProperty()
    totpts = db.IntegerProperty()
    #date = db.DateTimeProperty(auto_now_add=True)

class ViewPoints(webapp.RequestHandler):
    def get(self):
        points_query = Points.all().order("group")
        points = points_query.fetch(100) 

        leaderScore = None
        allSame = True
        for point in points:
            if leaderScore is None or point.totpts > leaderScore:
                leaderScore = point.totpts
            elif point.totpts != leaderScore: 
                allSame = False
        
        for point in points:
            if not allSame and leaderScore == point.totpts:
               point.leader = "T"
            else:
                point.leader = ""

        template_values = {
            'groupPoints': points,
            }

        path = os.path.join(os.path.dirname(__file__), 'view.html')
        self.response.out.write(template.render(path, template_values))

class AddPoints(webapp.RequestHandler):
    def get(self):
        group = str(self.get_group())
        points_query = Points.all().filter("group = ", group)
        points = points_query.fetch(1) 

        if len(points)==0:
            score = "Unknown"
        else:
            score = str(points[0].totpts)

        template_values = {
            'group': group,
            'currentScore':score,
            }

        path = os.path.join(os.path.dirname(__file__), 'add.html')
        self.response.out.write(template.render(path, template_values))
    
    def post(self):
        #group = self.request.get('group')
        group = str(self.get_group())
        
        points_query = Points.all().filter("group =", group)
        point = points_query.fetch(1)
        
        if len(point) == 0:
            point = Points()
            point.group = group
            point.r1pts = 0
            point.r2pts = 0
            point.totpts = 0
        else:
            point = point[0]
        
        amt_raw = self.request.get('amt')
        
        if amt_raw.startswith("R1:"):
            amt_raw = amt_raw.replace("R1:", "")
            point.r1pts += int(amt_raw)
        elif amt_raw.startswith("R2:"):
            amt_raw = amt_raw.replace("R2:", "")
            point.r2pts += int(amt_raw)
        else:
            assert False, amt_raw
        
        point.totpts = point.r1pts + point.r2pts
        
        #point.pointvalue = oint.pointvalue) +int(self.request.get('amt'))
        
        point.put()
        self.redirect('/add' + str(self.get_group()))

class AddPoints1(AddPoints):
    def get_group(self):
        return 1

class AddPoints2(AddPoints):
    def get_group(self):
        return 2

class AddPoints3(AddPoints):
    def get_group(self):
        return 3

class AddPoints4(AddPoints):
    def get_group(self):
        return 4
    
class AddPoints5(AddPoints):
    def get_group(self):
        return 5

class DeleteGroup(webapp.RequestHandler):
    def get(self):
        template_values = {}
        path = os.path.join(os.path.dirname(__file__), 'delete.html')
        self.response.out.write(template.render(path, template_values))
        
    def post(self):
        
        if self.request.get('reset'):
            points_query = Points.all()
            for point in points_query.fetch(1000):
                point.r1pts = 0
                point.r2pts = 0
                point.totpts = 0
                
                point.put()
        else:
            group = self.request.get('group')
            points_query = Points.all().filter("group =", group)
            points = points_query.fetch(1000)
            
            db.delete(points)
        
        self.redirect('/')

application = webapp.WSGIApplication([
                                    ('/', ViewPoints),
                                    ('/add1', AddPoints1),
                                    ('/add2', AddPoints2),
                                    ('/add3', AddPoints3),
                                    ('/add4', AddPoints4),
                                    ('/add5', AddPoints5),
                                    #('/addsub', AddPointsSubmit),
                                    ('/delete', DeleteGroup)
                                    ],
                                     debug=True)

def main():
    run_wsgi_app(application)

if __name__ == "__main__":
    main()