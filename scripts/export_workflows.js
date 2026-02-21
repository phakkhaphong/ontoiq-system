const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const workflows = [
  { id: '5oS1HrJDuVcmZXO0', name: 'embedding_pipeline.json' },
  { id: 'iU6LE7a6bkq98PG0', name: 'content_ingestion.json' },
  { id: 'Lys7fWPiBY88s0QG', name: 'human_in_loop_approval.json' },
  { id: 'itW8SZ6cLOPMF057', name: 'rag_query_api.json' },
  { id: 'hpD55UccqHb4uYVl', name: 'ai_analysis.json' }
];

const destDir = '/opt/ontoiq-system/n8n/workflows';

workflows.forEach(wf => {
  try {
    console.log(`Exporting ${wf.name}...`);
    // n8n CLI export
    execSync(`docker exec ontoiq-n8n n8n export:workflow --id=${wf.id} --output=/tmp/${wf.name}`);
    // Copy out of container
    execSync(`docker cp ontoiq-n8n:/tmp/${wf.name} ${path.join(destDir, wf.name)}`);
    console.log(`✅ Successfully exported ${wf.name}`);
  } catch (error) {
    console.error(`❌ Failed to export ${wf.name}:`, error.message);
  }
});
