import jenkins.model.Jenkins
import hudson.model.Job

def reallyDelete = true;

def rs = Fingerprint.RangeSet.fromString("342-360", false);

jobFullNameStr="[JOB]"

// println jobFullNameStr

def jobFullName = Jenkins.instance.getItemByFullName(jobFullNameStr);

// println("Job: ${jobFullName.fullName}");

def builds = jobFullName.getBuilds(rs);

if (builds.size()>0) {
  	println("Found ${builds.size()} builds for ${jobFullNameStr}");             
}

builds.each{ b->

  	if (reallyDelete) {
    	println("Deleting ${b}");
    	b.delete();
  	} else {
    	println("Found match ${b}");
  	}
} 
