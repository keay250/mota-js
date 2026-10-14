const fs = require('fs');
const vm = require('vm');

const dataContent = fs.readFileSync('_analysis/_ybfh-mota/project/data.js', 'utf8');
const sandbox = { 
  data_a1e2fb4a_e986_4524_b0da_9b7ba7c0874d: {},
  main: { floors: {} }
};
vm.createContext(sandbox);
vm.runInContext(dataContent, sandbox);
const data = sandbox.data_a1e2fb4a_e986_4524_b0da_9b7ba7c0874d;

const floors = {};
for (const floorId of data.main.floorIds) {
  const filePath = '_analysis/_ybfh-mota/project/floors/' + floorId + '.js';
  const content = fs.readFileSync(filePath, 'utf8');
  vm.runInContext(content, sandbox);
  floors[floorId] = sandbox.main.floors[floorId];
}

console.log('=== 全量楼层出入口拓扑审计 ===');
let errors = 0;
for (const [floorId, floor] of Object.entries(floors)) {
  const changeFloor = floor.changeFloor || {};
  for (const [coord, target] of Object.entries(changeFloor)) {
    const [fromX, fromY] = coord.split(',').map(Number);
    const targetFloorId = target.floorId;
    if (!floors[targetFloorId]) {
      console.error(`❌ [${floorId}] (${fromX},${fromY}) 指向不存在的楼层: ${targetFloorId}`);
      errors++;
      continue;
    }
    const targetFloor = floors[targetFloorId];
    const [toX, toY] = target.loc || (targetFloor.upFloor || targetFloor.downFloor || [0,0]);
    
    // 检查落点坐标是否在目标楼层范围内
    if (toX < 0 || toX >= targetFloor.width || toY < 0 || toY >= targetFloor.height) {
      console.error(`❌ [${floorId}] (${fromX},${fromY}) -> [${targetFloorId}] 落点越界: (${toX},${toY}) 地图尺寸: ${targetFloor.width}x${targetFloor.height}`);
      errors++;
      continue;
    }
    
    // 检查落点是否是另一个 changeFloor (直接对撞循环)
    const targetChanges = targetFloor.changeFloor || {};
    const key = toX + ',' + toY;
    if (targetChanges[key]) {
      console.warn(`⚠️ [${floorId}] (${fromX},${fromY}) -> [${targetFloorId}] 落点 (${toX},${toY}) 恰好也是传送点！可能会产生对撞死循环！`);
      errors++;
    } else {
      console.log(`✅ [${floorId}] (${fromX},${fromY}) -> [${targetFloorId}] 安全落点 (${toX},${toY})`);
    }
  }
}

if (errors === 0) {
  console.log('\n🎉 所有 13 个楼层出入口拓扑与落点 100% 安全健康，无越界，无对撞死循环！');
} else {
  console.error(`\n⚠️ 共发现 ${errors} 个拓扑异常，需处理！`);
}
